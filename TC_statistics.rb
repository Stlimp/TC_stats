nning=Time.now



logs_path= "/home/st/Ruby/testdir/"
output_file="/home/st/Ruby/report.txt"
DEBUG=false


#file_name = Dir.glob("#{logs_path}*.tgz")
#file_name.each do |testname|
#puts testname = /-/.match(testname).pre_match
#puts testname
#end
#titan = IO.read("#{logs_path}titan.cfg")

test_results=Array.new
Dir.chdir(logs_path)
Dir.glob("*.tgz").each do |filename|
 # puts /-/.match(filename).pre_match #unless filename =~ /^\.\.?$/
	test_results.push filename

end

if DEBUG
	puts "Test results"
	puts test_results
	puts
end

titan=File.open("#{logs_path}titan.cfg","rb")


#getting list of testcases ->hash
testcases_full_names=Hash.new {|testname,verdict|}
@found=false;
titan.each_line do |line|
	if @found
		#testcases.push line.match(/\./).post_match.strip
		testcases_full_names[line.strip]=""
	end
	if line =~ /\[EXECUTE\]/
		@found=true
	end
end

if DEBUG
	puts "Testcases full names:"
	puts testcases_full_names
	puts
end

testcases_short_names=Array.new
testcases_full_names.keys.each do |testname|
	testcases_short_names.push testname.match(/\./).post_match
end


if DEBUG 
	puts "Testcases short names:"
	puts testcases_short_names
	puts
end;


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
if DEBUG
	puts "Pass array:"
	puts pass_array
	puts "Fail array:"
	puts fail_array
	puts "Error array:"
	puts error_array
	puts
end



testcases_full_names.keys.each do |test_full_name|
 if error_array.include?(test_full_name.match(/\./).post_match)
 	testcases_full_names[test_full_name]="error"
 end
 if fail_array.include?(test_full_name.match(/\./).post_match)
 	if testcases_full_names[test_full_name]==""
		testcases_full_names[test_full_name]="fail"
	elsif  	testcases_full_names[test_full_name]=="error"
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

#puts "SORTED HASH"
##Working
testcases_full_names = testcases_full_names.group_by{|key,value| value}
if DEBUG
	puts "Testcases with verdicts:"
	testcases_full_names.each do |key,value|
		puts key
		value.each do |k,v|;puts k;end
	end
end


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

=begin
report =File.open(output_file,"w")
testcases_full_names.each do |key,value|
	if value=="pass_on_rerun"
	report.write(key)
end
end
testcases_full_names.each do |key,value|
	if value=="pass"
	report.write(key)
end
end
testcases_full_names.each do |key,value|
	if value=="fail"
	report.write(key)
end
end
testcases_full_names.each do |key,value|
	if value=="error"
	report.write(key)
end
end
testcases_full_names.each do |key,value|
	if value=="fail/error"
	report.write(key)
end
end
testcases_full_names.each do |key,value|
	if value==""
	report.write(key)
end
end

report.close
=end



puts "Time elapsed #{Time.now - beginning} seconds"
#if DEBUG
#puts (pass_array&fail_array).include?("TC_MMTCG_NCBP001")
#puts
#puts fail_array&error_array
#puts
#puts error_array&pass_array&fail_array
#puts
#end


#testcases.each do |testcase|
#	test_results.each do |results|
#		#printf testcase
#		puts results.match(testcase)
#	end
#end




#string = "The force will be with you always"
#puts my_match = /force/.match(string).pre_match



#@found=true 
#if $_ =~ /\[EXECUTE\]/; next unless @found'<titan

