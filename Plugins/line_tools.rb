class LineTools < Plugin
   class << self
      attr_accessor :enabled
      attr_accessor :original_clipboard
      attr_accessor :map
      attr_accessor :app_list


      def toggle
         @enabled = !@enabled

         system (@enabled ? '/usr/local/bin/growlnotify -m "" -a Keymando Line tools enabled.' : '/usr/local/bin/growlnotify -m "" -a Keymando Line tools disabled.')

      end


      def stash_clipboard
         s = IO.popen('pbpaste', 'r+').read
         @original_clipboard = s
      end

      def enabled?
         @enabled
      end
   end

   def before
      LineTools.map = "<Ctrl- >"
      LineTools.app_list = [/Coda/]

   end

   def after
      LineTools.app_list.each do |app|
         only app do
            map LineTools.map do
               LineTools.toggle
               LineTools.enabled? ? set_maps : un_set_maps
            end
         end
      end

   end

   def clip
      send("<Cmd-c>")
      sleep(0.5)
      IO.popen('pbpaste', 'r+').read.strip
   end

   def reset
      IO.popen('pbcopy', 'w') {|c| c.write LineTools.original_clipboard}
   end

   def un_set_maps
      m = unmap("dd")

      m.reject! {|d| true if d.source == 'dd'}
      m.reject! {|d| true if d.source == 'ud'}
      m.reject! {|d| true if d.source == 'nd'}
      m.reject! {|d| true if d.source == 'x'}
      m.reject! {|d| true if d.source == 'ci'}
      m.reject! {|d| true if d.source == 'nf'}
      m.reject! {|d| true if d.source == 'fq'}
   end


   def set_maps

      map "dd" do
         LineTools.stash_clipboard
         send("<Ctrl-Left>")
         send("<Shift-Ctrl-Right>")
         line = clip
         send("<Right>")
         send("<Return>")
         send("<Ctrl-Left>")
         send("<Cmd-v>")
         reset
      end

      map "ud" do
         LineTools.stash_clipboard
         send("<Ctrl-Left>")
         send("<Shift-Ctrl-Right>")
         line = clip
         send("<Left>")
         send("<Left>")
         send("<Return>")
         send("<Ctrl-Left>")
         send("<Cmd-v>")
         reset
      end
      map "nd" do
         LineTools.stash_clipboard
         send("<Ctrl-Left>")
         send("<Shift-Ctrl-Right>")
         line = clip
         line = line.gsub(/\d+/) do |match|
            match.to_i + 1
         end
         IO.popen('pbcopy', 'w') {|c| c.write line}
         send("<Right>")
         send("<Return>")
         send("<Ctrl-Right>")
         send("<Cmd-v>")
         reset
      end

      map "x" do
         LineTools.stash_clipboard
         send("<Ctrl-Left>")
         send("<Shift-Ctrl-Right>")
         send("<Delete><Delete>")
      end
      
      map "ci" do
        replace = LineTools.stash_clipboard
        send("<Shift-Ctrl-Left>")
        line = clip
        lines = replace.split(/\n/)
        paste_at = line.length
        send("<Left>")
       
        (lines.length).times do |x|
           IO.popen('pbcopy', 'w') {|c| c.write lines[x]}
           paste_at.times {send("<Right>")}
           send('<Cmd-v>')
           sleep(0.5)
           send("<Ctrl-Left>")
           send("<Down>")
        end
         reset      
        
      end
      
      map "nf" do
        LineTools.stash_clipboard
        lines = clip
        num = 0
        lines = lines.gsub(/#/) do |match|
            num = num + 1
        end
        IO.popen('pbcopy', 'w') {|c| c.write lines}
        send('<Cmd-v>')
        sleep(0.5)
        reset
      end
      
      map "fq" do
        fill = LineTools.stash_clipboard
        lines = clip
        lines = lines.gsub(/"[^"]*"/) do |match|
            "\"#{fill}\""
        end
        IO.popen('pbcopy', 'w') {|c| c.write lines}
        send('<Cmd-v>')
        sleep(0.5)
        reset
      end

   end


end

