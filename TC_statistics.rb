#!/usr/bin/env ruby

#TODO 
#  0. Comment code
#  1. Naming conventions (https://github.com/bbatsov/ruby-style-guide, https://github.com/bbatsov/rubocop)
#  done Read parameters from cmd(http://stackoverflow.com/questions/9897593/accepting-command-line-arguments-into-a-ruby-script)
#  3. Read and write to report TTCN labels
#  4. Parse tiger.cfg for build label
#  5. Better format of report
#  6. Remove unnessesesary variables
#  7. Report improvement
#  done Remove hardcoded strings
#  9. Remove hardcode for titan.cfg
#TODO


case ARGV[0].nil?
when false
	logs_path=ARGV[0]
else
	puts <<-EOF
	USAGE: TC_statistics.rb logs_path TC_list_file
	OR: TC_statistics.rb logs_path (TC list will be taken from titan.cfg)
	OUTPUT: report.txt in current dir
	EOF
	exit 1
end

case ARGV[1].nil?
when false
	titan_cfg=ARGV[1]
else
	titan_cfg="#{Dir.home}/GIT/testdir/titan.cfg"
end

beginning=Time.now

if !File.writable?(Dir.pwd)
    puts "Can't create report in given directory. Exit"
    exit
end

output_file="#{Dir.pwd}/report.txt"
DEBUG=false


test_results=Array.new
Dir.chdir(logs_path)
Dir.glob("*.tgz").each do |filename|
test_results.push filename

end
if File.exists?(titan_cfg)
    titan=File.open(titan_cfg,"rb")
else
    puts "titan.cfg not found"
    exit 
end

#getting list of testcases ->hash
testcases_full_names=Hash.new {|testname,verdict|}
@found=false;


case ARGV[1].nil?
when true 
	titan.each_line do |line|
    	if @found
        	testcases_full_names[line.strip]=""
    	end
    	if line =~ /\[EXECUTE\]/
        	@found=true
    	end
	end
when false
	titan.each_line do |line|
		testcases_full_names[line.strip]=""
	end
end
titan.close()


testcases_short_names=Array.new
testcases_full_names.keys.each do |testname|
    testcases_short_names.push testname.match(/\./).post_match
end

#Pass Hash
pass_array=Array.new
fail_array=Array.new
error_array=Array.new

test_results.each do |result|
    if result.match("pass") 
        pass_array.push result.match("-").pre_match
    end
    if result.match("fail") 
        fail_array.push result.match("-").pre_match
    end
    if result.match("error") 
        error_array.push result.match("-").pre_match
    end
end

testcases_full_names.keys.each do |test_full_name|
    if error_array.include?(test_full_name.match(/\./).post_match)
         testcases_full_names[test_full_name]="error"
     end
    if fail_array.include?(test_full_name.match(/\./).post_match)
        if testcases_full_names[test_full_name]==""
            testcases_full_names[test_full_name]="fail"
        elsif      testcases_full_names[test_full_name]=="error"
            testcases_full_names[test_full_name]="fail/error"
        end
    end
    if pass_array.include?(test_full_name.match(/\./).post_match)
        if testcases_full_names[test_full_name]==""
            testcases_full_names[test_full_name]="pass"
        else
            testcases_full_names[test_full_name]="pass_on_rerun"
        end
    end
end

##Working
testcases_full_names = testcases_full_names.group_by{|key,value| value}
if DEBUG
    puts "Testcases with verdicts:"
    testcases_full_names.each do |key,value|
        puts key
        value.each do |k,v|;puts k;end
    end
end

#Create report
report = File.open(output_file,"w")
testcases_full_names.each do |key,value|
if key!=""
        report.write("===========================#{key.upcase}============================\n")
    else
        report.write("==========NOT EXECUTED(missing logs in given directory)====\n")
    end
    value.each do |k,v|;report.write("#{k}\n");end
end
report.close

puts "Time elapsed #{Time.now - beginning} seconds"
