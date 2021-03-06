TEXTMATE_FILE="TEXTMATE"
WAX_PATH = File.expand_path("wax")

desc "Create a Wax TextMate project"
task :tm => "TEXTMATE" do
  sh "mate #{TEXTMATE_FILE} ./data ./wax/lib/wax-scripts"
  sh "mate #{TEXTMATE_FILE}"
end

namespace :tm do
  desc "Install textmate lua & wax bundles"
  task :install_bundles do
    sh "mkdir -p ~/Library/Application\\ Support/TextMate/Bundles/"
    
    lua_bundle_dir = "~/Library/Application\\ Support/TextMate/Bundles/Lua.tmbundle"
    if not sh("test -e #{lua_bundle_dir}") {|ok, status| ok} # This is bad code...
      sh "curl -L http://github.com/textmate/lua.tmbundle/tarball/master | tar xvz"
      sh "mv textmate-lua.tmbundle* #{lua_bundle_dir}"
    end

    wax_bundle_dir = "~/Library/Application\\ Support/TextMate/Bundles/Wax.tmbundle"
    if not sh("test -e #{wax_bundle_dir}") {|ok, status| ok}
      sh "curl -L http://github.com/probablycorey/Wax.tmbundle/tarball/master | tar xvz"
      sh "mv probablycorey-[Ww]ax.tmbundle* #{wax_bundle_dir}"
    end
  end

  file TEXTMATE_FILE do |t|
    open(t.name, "w") do |file|
      file.write <<-TEXTMATE_HELP
Some tips to make life easier

1) Install the Lua and Wax TextMate Bundles.
  a) Either type "rake tm:install_bundles"
  
     Or, you can manually install the bundles from 
     http://github.com/textmate/lua.tmbundle and
     http://github.com/probablycorey/Wax.tmbundle
     into ~/Library/Application\ Support/TextMate/Bundles
     
  b) From TextMate click Bundles > Bundle Editor > Reload Bundles
  
      TEXTMATE_HELP
    end
  end
end

desc "Update the wax lib with the lastest code"
task :update do
  puts
  puts "User Input Required!"
  puts "--------------------"  
  print "About to remove wax directory '#{WAX_PATH}' and replace it with an updated version (y/n) "

  if STDIN.gets !~ /^y/i
    puts "Exiting... nothing was done!"
    return
  end  
  
  tmp_dir = "./_wax-download"
  rm_rf tmp_dir
  mkdir_p tmp_dir
  sh "curl -L http://github.com/probablycorey/wax/tarball/master | tar -C #{tmp_dir} -x -z"  
  rm_rf WAX_PATH
  sh "mv #{tmp_dir}/* \"#{WAX_PATH}\""
  rm_rf tmp_dir
end

desc "Git specific tasks"
namespace :git do
  
  desc "make the wax folder a submodule"
  task :sub do
    rm_rf WAX_PATH
    sh "git init"
    sh "git submodule add git://github.com/probablycorey/wax.git wax"
  end
end

desc "Build and run tests on the app"
task :test do
  sh "#{WAX_PATH}/bin/hammer --test"
end

desc "Build"
task :build do
  sh "#{WAX_PATH}/bin/hammer"
end

desc "Build and run the app"
task :run do
  sh "#{WAX_PATH}/bin/hammer --run"
end