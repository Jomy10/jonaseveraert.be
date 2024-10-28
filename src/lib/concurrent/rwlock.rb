require 'concurrent'
require 'concurrent-edge'

# ReadWriteLock without max readers/writers
class RWLock < Concurrent::Synchronization::Object
  def initialize
    super

    @writeLocked = Concurrent::AtomicBoolean.new(false)
    @waitingWriterCounter = Concurrent::AtomicFixnum.new(0)
    @readerCounter = Concurrent::AtomicFixnum.new(0)
    @readLock = Concurrent::Synchronization::Lock.new
    @writeLock = Concurrent::Synchronization::Lock.new
  end

  def acquire_read_lock
    while true
      if self.waiting_writer?
        @readLock.wait_until { !self.waiting_writer? }

        while true
          if self.write_locked?
            @readLock.wait_until { !self.write_locked? }
          else
            c = @readerCounter.value
            return if @readerCounter.compare_and_set(c, c+1)
          end
        end
      else
        c = @readerCounter.value
        break if @readerCounter.compare_and_set(c, c+1)
      end
    end

    return true
  end

  def release_read_lock
    while true
      c = @readerCounter.value
      if @readerCounter.compare_and_set(c, c-1)
        if self.waiting_writer? && c == 0
          @writeLock.signal
        end
        break
      end
    end

    return true
  end

  def acquire_write_lock
    while true
      rc = @readerCounter.value
      wrc = @waitingWriterCounter.value

      if rc == 0 && !self.write_locked?
        break if @writeLocked.make_true
      elsif @waitingWriterCounter.compare_and_set(wrc, wrc+1)
        while true
          @writeLock.wait_until do
            !self.write_locked? && !self.running_readers?
          end

          break if @writeLocked.make_true
        end
        break
      end
    end

    return true
  end

  def release_write_lock
    return true unless write_locked?
    return false unless @writeLocked.make_false
    @readLock.broadcast
    @writeLock.signal if waiting_writer?
    return true
  end

  def write_locked?
    @writeLocked.true?
  end

  def waiting_writer?
    @waitingWriterCounter.value > 0
  end

  def running_readers?
    @readLocked.value > 0
  end
end
