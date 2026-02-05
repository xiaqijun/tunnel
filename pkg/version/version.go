package version

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"runtime"
	"time"
)

// 版本信息
const (
	Version   = "1.0.2"
	GitCommit = ""
	BuildDate = ""
)

// VersionInfo 版本信息结构
type VersionInfo struct {
	Version   string `json:"version"`
	GitCommit string `json:"git_commit,omitempty"`
	BuildDate string `json:"build_date,omitempty"`
	GoVersion string `json:"go_version"`
	OS        string `json:"os"`
	Arch      string `json:"arch"`
}

// Get 获取当前版本信息
func Get() *VersionInfo {
	return &VersionInfo{
		Version:   Version,
		GitCommit: GitCommit,
		BuildDate: BuildDate,
		GoVersion: runtime.Version(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}
}

// String 返回版本字符串
func (v *VersionInfo) String() string {
	return fmt.Sprintf("Tunnel %s (%s/%s)", v.Version, v.OS, v.Arch)
}

// GitHubRelease GitHub发布信息
type GitHubRelease struct {
	TagName     string    `json:"tag_name"`
	Name        string    `json:"name"`
	Body        string    `json:"body"`
	PublishedAt time.Time `json:"published_at"`
	Assets      []struct {
		Name        string `json:"name"`
		DownloadURL string `json:"browser_download_url"`
		Size        int64  `json:"size"`
	} `json:"assets"`
}

// CheckUpdate 检查GitHub更新
func CheckUpdate(repo string) (*GitHubRelease, bool, error) {
	url := fmt.Sprintf("https://api.github.com/repos/%s/releases/latest", repo)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		return nil, false, fmt.Errorf("failed to check update: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, false, fmt.Errorf("GitHub API returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, false, fmt.Errorf("failed to read response: %v", err)
	}

	var release GitHubRelease
	if err := json.Unmarshal(body, &release); err != nil {
		return nil, false, fmt.Errorf("failed to parse response: %v", err)
	}

	// 比较版本（简单的字符串比较）
	hasUpdate := release.TagName > "v"+Version

	return &release, hasUpdate, nil
}

// GetDownloadURL 获取当前平台的下载链接
func (r *GitHubRelease) GetDownloadURL(component string) string {
	filename := fmt.Sprintf("tunnel-%s-%s-%s", r.TagName, runtime.GOOS, runtime.GOARCH)

	// 根据操作系统确定扩展名
	if runtime.GOOS == "windows" {
		filename += ".zip"
	} else {
		filename += ".tar.gz"
	}

	// 查找匹配的资源
	for _, asset := range r.Assets {
		if asset.Name == filename {
			return asset.DownloadURL
		}
	}

	return ""
}
