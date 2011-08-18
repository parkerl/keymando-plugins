class Testwhat < Plugin
   def before 
   map "<Ctrl-;>" do
      NSWorkspace.sharedWorkspace.runningApplications.each do |x|
        @app = x if x.ownsMenuBar
      end
      
      alert(@app.localizedName)
      
      
   end
   end
end
