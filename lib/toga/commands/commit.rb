require 'git'
require 'yaml'

module Toga
  module Commands
    class Commit < Command
      include Error
      
      def self.run!(args)
        git = Git.open(Dir.getwd)
        untracked = git.status.untracked!.keys
        modified = git.status.modified.keys
        added = git.status.added.keys
        
        # Get the git message to commit with
        message = Toga::Commands::Top.run!
        if args.count > 0
          task_search = args.join(' ')
          full, group, offset = Togafile.search(task_search)
          message = full
        end
        
        puts "Committing task:\n  #{message}\n\n"
        
        # Show the user the files they're leaving behind and ask to continue or die
        files_to_add = '.'
        if untracked.count > 0 || modified.count > 0 || added.count == 0
          if untracked.count > 0
            files_to_add = [] if files_to_add.is_a? String
            puts error("You didn't add the following files:\n")
            files_to_add.concat untracked
            puts untracked.join("\n") + "\n\n"
          end
          
          if modified.count > 0
            puts error("The following files are modified, but their changes aren't added:\n")
            puts modified.join("\n") + "\n\n"
          end
          
          if added.count == 0 && untracked.count == 0
            changed = git.status.changed.keys
            files_to_add = [] if files_to_add.is_a? String
            files_to_add.concat changed
            puts error("The following files are modified, but their changes aren't added:\n")
            puts changed.join("\n") + "\n\n"
          end
          
          puts "Continue committing? [y/a/n] (
  y: continue, don't stage
  a: add them using git add #{files_to_add}
  n: cancel/exit)"
          continue = $stdin.gets
          response = continue[0].downcase
          if !["a", "y"].include? response
            return 0
          end
          
          if response == "a"
            git.add(files_to_add)
            puts "Added:\n" + (untracked + modified + (changed || [])).join("\n")
          end
        end
        
        # Okay, files are all ready for commit.
        
        # Print off files
        
        
        # Prepare git commit.
        git.status.added.keys.each do |filename|
          puts "# Staged: #{filename}"
        end
        
        puts "# Add an optional message (or press enter): "
        full_message = message << "\n\n" << $stdin.gets
        `git commit -m "#{full_message.gsub(/"/, '\"')}"`
        
        Commands::Complete.run!(message)
      end
    end
  end
end