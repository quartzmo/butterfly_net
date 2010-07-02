module ButterflyNet
  class FileWriter

    def initialize(filename)
      @file = File.open(filename, 'a+')
      @filename = filename
    end

    def write(data)
      @file = File.open(@filename, 'a+')      
      @file.write data
      @file.close      
    end

    def create_file(data)
      @file.puts data
      true
    ensure
      if @file # todo: closing is always good, but prevent writing partial data in case of exception
        @file.close
      end
    end

    def close
      if @file # todo: closing is always good, but prevent writing partial data in case of exception
        @file.close
      end
    end

  end
end