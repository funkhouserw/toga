module Toga
  module Commands
    class Complete < Command
      
      def self.run!(*args)
        prefix = args.join(' ')
        Togafile.move prefix, {:current => :completed}, {prepend: true}
      end
    end
  end
end