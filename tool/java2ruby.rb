
class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  # ignore capitalized camel cases
  def underscore_vars
    self.gsub(/\b[a-z][a-z]*(?:[A-Z][a-z]*)(?:[A-Z][a-z]*)*\b/) {|word|
      word.underscore
    }
  end
end

class Java2Ruby
  attr_accessor :file, :java, :ruby

  @@conf = {
    :java_base => 'C:/dev/picsy/original/PICSY2/src/org/picsy/',
    :ruby_base => 'C:/dev/picsy/picsy-rails/lib/picsy/',
  }

  def initialize(file, output)
    if file.nil?
      raise "please specify filename: java2ruby.rb [filename]"
    end
    @file = file
    @java_file = @@conf[:java_base] + @file + ".java"
    @ruby_file = @@conf[:ruby_base] + @file.underscore + ".rb"
    if !File.exists?(@java_file)
      raise "file #{@java_file} not found."
    end
    @java = File.read(@java_file)
    @output = output
  end

  def convert
    @ruby = @java.dup
    @ruby = @ruby.underscore_vars
    @ruby = @ruby.gsub(%r!\t!, '  ')
                 .gsub(%r!\}$!, 'end')
                 .gsub(%r!\) \{$!, ')')
                 .gsub(%r! \{$!, '')
                 .gsub(%r!;\s*$!, '')
                 .gsub(%r!if \(([^\)]+)\)!, 'if \1')
                 .gsub(%r!\} else!, 'else')
                 .gsub(%r!throw new (\w+)!, 'raise \1.new')
                 .gsub(%r!public static \w+ (.+\()!, 'def self.\\1')
                 .gsub(%r!public \w+ (.+\()!, 'def \\1')
                 .gsub(%r!\b(int|double|String|boolean|Object) !, '')
                 .gsub(%r!^(\s*)\/\*\*?\s+!, '')
                 .gsub(%r!^(\s*)\* !, '\\1# ')
                 .gsub(%r!^(\s*)\*\/\s+!, '')
                 .gsub(%r!\/\/!, '# ')
                 .gsub(%r!^package.+!, '')
                 .gsub(%r!^public class!, 'class')
                 .gsub(%r! extends !, ' < ')
                 .gsub(%r!\(\)\s*\{?\s*$!, '')
                 .gsub(%r!this\.!, 'self.')
                 .gsub(%r!public [A-Z]\w+\(!, 'def initialize(') # constructor
                 .gsub(%r!this\(!, 'initialize(')
                 .gsub(%r!public static final !, '')
                 .gsub(%r!private final !, 'attr_accessor :')
  end

  def output
    if @output
      File.open(@ruby_file, "w") do |f|
        f.puts @ruby
      end
      puts "saved to #{@ruby_file}"
    else
      puts @ruby
    end
  end

end

file = ARGV[0]
output = ARGV[1]
j2r = Java2Ruby.new(file, output)
j2r.convert
j2r.output

