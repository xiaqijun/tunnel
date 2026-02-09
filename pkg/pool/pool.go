package pool

import (
	"sync"
)

// BufferPool 缓冲池
type BufferPool struct {
	pool *sync.Pool
	size int
}

// NewBufferPool 创建缓冲池
func NewBufferPool(size int) *BufferPool {
	return &BufferPool{
		size: size,
		pool: &sync.Pool{
			New: func() interface{} {
				return make([]byte, size)
			},
		},
	}
}

// Get 获取缓冲区
func (p *BufferPool) Get() []byte {
	return p.pool.Get().([]byte)
}

// Put 归还缓冲区
func (p *BufferPool) Put(buf []byte) {
	if cap(buf) == p.size {
		p.pool.Put(buf[:p.size])
	}
}

// WorkerPool 协程池
type WorkerPool struct {
	tasks   chan func()
	workers int
	wg      sync.WaitGroup
}

// NewWorkerPool 创建协程池
func NewWorkerPool(workers int) *WorkerPool {
	pool := &WorkerPool{
		tasks:   make(chan func(), workers*2),
		workers: workers,
	}

	pool.start()
	return pool
}

// start 启动工作协程
func (p *WorkerPool) start() {
	for i := 0; i < p.workers; i++ {
		p.wg.Add(1)
		go func() {
			defer p.wg.Done()
			for task := range p.tasks {
				task()
			}
		}()
	}
}

// Submit 提交任务
func (p *WorkerPool) Submit(task func()) {
	p.tasks <- task
}

// Stop 停止协程池
func (p *WorkerPool) Stop() {
	close(p.tasks)
	p.wg.Wait()
}

// ConnPool 连接池
type ConnPool struct {
	conns chan interface{}
}

// NewConnPool 创建连接池
func NewConnPool(size int) *ConnPool {
	return &ConnPool{
		conns: make(chan interface{}, size),
	}
}

// Get 获取连接
func (p *ConnPool) Get() (interface{}, bool) {
	select {
	case conn := <-p.conns:
		return conn, true
	default:
		return nil, false
	}
}

// Put 归还连接
func (p *ConnPool) Put(conn interface{}) bool {
	select {
	case p.conns <- conn:
		return true
	default:
		return false
	}
}

// Close 关闭连接池
func (p *ConnPool) Close() {
	close(p.conns)
}
