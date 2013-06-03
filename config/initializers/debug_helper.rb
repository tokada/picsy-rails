require 'pp'
require 'nkf'

module DebugHelper

  # テスト環境以外でputsする
  def puts_d(*obj_array)
    return if RAILS_ENV=="test"
    for obj in obj_array
      puts "#{obj}"
    end
  end

  # for debug use
  def dd(*obj_array)
    puts "\n------------------------------------------------------------\n"
    for obj in obj_array
      puts "at #{caller(4).first}\n"
      puts "\e[33m" + obj.pretty_inspect + "\e[0m"
      puts "------------------------------------------------------------\n"
    end
  end

  def dd_present(*obj_array)
    dd(*obj_array) unless obj_array.flatten.blank?
  end

  # pass any command by string to show the eval result as well as the command itself
  def d_eval(*str_array)
    puts "\n------------------------------------------------------------\n"
    for str in str_array
      puts "at #{caller(3).first}\n"
      puts "result of \e[33m#{str}\e[0m"
      puts "\e[32m" + eval(str).pretty_inspect + "\e[0m"
      puts "------------------------------------------------------------\n"
    end
  end

  # passing Japanese string to Windows system
  def d_sjis(*obj_array)
    puts "\n------------------------------------------------------------\n"
    for obj in obj_array
      puts "at #{caller(3).first}\n"
      puts NKF.nkf('-s', obj.inspect)
      puts "------------------------------------------------------------\n"
    end
  end

  def dd_dtree(dtree)
    puts "### Tokens"
    dtree.tokens.each do |token|
      printf "%2d.%-2d %s  [%s]\n",
      token.chunk_id,
      token.token_id,
      token.surface.split(//)[0...10].join,
      token.feature.split(',')[0..3].join(',')
    end

    puts ""
    puts "### Links"
    dtree.links.each do |link|
      from_tokens = dtree.find(:chunk_id => link[1]).sort{|x,y| x.token_id <=> y.token_id }
      to_tokens = dtree.find(:chunk_id => link[0]).sort{|x,y| x.token_id <=> y.token_id }

      from_chunk_surface = from_tokens.map{|t| t.surface}.join
      to_chunk_surface = to_tokens.map{|t| t.surface}.join

      printf "[%d: %s] -> [%d: %s]\n",
      link[1],
      from_chunk_surface,
      link[0],
      to_chunk_surface
    end
  end

  def dd_doc(doc)
    dd_dtree(doc.sentences.first.dtree)
  end

  def dd_ts(token_sets)
    dd token_sets.map{|ts| ts.tokens.map{|t| [{:s=>t.surface}, {:f=>t.feature}, {:t=>t.tag }]}}
  end

  # 処理時間計測
  def d_time(msg="")
    if defined?(@@last_d_time)
      passed_time = sprintf('%0.02f', Time.now - @@last_d_time)
      dd "#{msg}: #{passed_time} secs"
    end
    @@last_d_time = Time.now
  end
end

include DebugHelper
ActiveRecord::Base.class_eval { include DebugHelper; extend DebugHelper }
ActionController::Base.class_eval { include DebugHelper }
ApplicationHelper.class_eval { include DebugHelper }
