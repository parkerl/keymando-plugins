class InspectKeymando < Plugin
  
  def after
     map "<Ctrl-i>" do
       m = "\n--------------------------------------------------\n Instance Methods \n---------------------------------------\n"
       m = m + self.methods.sort.join("\n")
       m = m + "\n--------------------------------------------------\n Class Methods \n---------------------------------------\n"
       m = m + self.class.methods.sort.join("\n")
       m = m + "\n--------------------------------------------------\n Class Ancestors \n---------------------------------------\n"
       m = m + self.class.ancestors.join("\n")
       IO.popen('pbcopy', 'w').puts m
       sleep(3)
       send "<Cmd-v>"
     end
  end
  
end