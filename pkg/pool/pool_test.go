package pool

import (
	"sync"
	"testing"
)

// BenchmarkBufferPool 测试缓冲池性能
func BenchmarkBufferPool(b *testing.B) {
	pool := NewBufferPool(8192)
	
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			buf := pool.Get()
			pool.Put(buf)
		}
	})
}

// BenchmarkBufferPoolWithoutPool 测试不使用缓冲池的性能
func BenchmarkBufferPoolWithoutPool(b *testing.B) {
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			buf := make([]byte, 8192)
			_ = buf
		}
	})
}

// BenchmarkWorkerPool 测试协程池性能
func BenchmarkWorkerPool(b *testing.B) {
	pool := NewWorkerPool(100)
	defer pool.Stop()
	
	var wg sync.WaitGroup
	
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		wg.Add(1)
		pool.Submit(func() {
			// 模拟工作负载
			sum := 0
			for j := 0; j < 1000; j++ {
				sum += j
			}
			wg.Done()
		})
	}
	wg.Wait()
}

// BenchmarkWorkerPoolWithoutPool 测试不使用协程池的性能
func BenchmarkWorkerPoolWithoutPool(b *testing.B) {
	var wg sync.WaitGroup
	
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		wg.Add(1)
		go func() {
			// 模拟工作负载
			sum := 0
			for j := 0; j < 1000; j++ {
				sum += j
			}
			wg.Done()
		}()
	}
	wg.Wait()
}

// TestBufferPool 测试缓冲池功能
func TestBufferPool(t *testing.T) {
	pool := NewBufferPool(1024)
	
	// 测试获取和归还
	buf1 := pool.Get()
	if len(buf1) != 1024 {
		t.Errorf("Expected buffer size 1024, got %d", len(buf1))
	}
	
	pool.Put(buf1)
	
	buf2 := pool.Get()
	if len(buf2) != 1024 {
		t.Errorf("Expected buffer size 1024, got %d", len(buf2))
	}
}

// TestWorkerPool 测试协程池功能
func TestWorkerPool(t *testing.T) {
	pool := NewWorkerPool(10)
	defer pool.Stop()
	
	var wg sync.WaitGroup
	counter := 0
	var mu sync.Mutex
	
	// 提交100个任务
	for i := 0; i < 100; i++ {
		wg.Add(1)
		pool.Submit(func() {
			mu.Lock()
			counter++
			mu.Unlock()
			wg.Done()
		})
	}
	
	wg.Wait()
	
	if counter != 100 {
		t.Errorf("Expected counter to be 100, got %d", counter)
	}
}
