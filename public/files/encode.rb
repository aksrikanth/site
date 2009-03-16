#!/usr/bin/env ruby

# == Synopsis
# encode : encodes a stream to video
#
# == Usage
#
# encode [OPTION] ...
#
# -h, --help ::
# 	show help
# -n, --name ::
# 	name of output file
# -d, --dev ::
# 	device or file on which to operate
# -v, --vcodec ::
# 	codec to use for video encoding
# -a, --acodec ::
# 	codec to use for audio encoding
# -b, --bpp ::
# 	bits per pixel
# -f, --fps ::
# 	frames per second of input
# -q, --aquality ::
# 	quality of audio encoding
# -c, --crop ::
# 	crop the video to given size
# -e, --extraopts ::
# 	provide extra arguments like length of encoding(for  testing only)
# -i, --input ::
# 	ask for confirmation at each step
# -t, --test ::
# 	print the commands that will be run without actual encoding
#
# == Author
#
# Srikanth K. Agaram, University of California, Irvine
#
# == Copyright
# Copyright (c) 2006 Srikanth Agaram. Licenced under the GNU GPLv2

require 'getoptlong'
require 'rdoc/usage'

class Encode
	attr_reader :dev, :name, :vcodec, :acodec, :bpp, :fps, :aquality, :crop, :input, :extraopts, :aids, :sids
	attr_writer :dev, :name, :vcodec, :acodec, :bpp, :fps, :aquality, :crop, :input, :extraopts, :run

	GRAY="\033[1;30m"
	LIGHT_GRAY="\033[0;37m"
	WHITE="\033[1;37m"
	NO_COLOR="\033[0m"
	GREEN="\033[01;32m"
	LIGHT_BLUE="\033[1;34m"
	YELLOW="\033[1;33m"
	LIGHT_RED="\033[1;31m"

	def initialize()
		@run = true
		@crop = nil
		@scale = nil
		@aquality=3
		@acodec='mp3'
		@bpp = 0.23
		@vcodec = 'lavc'
		@name = 'encodeOut'
		@dev = 'dvd://1'
		@fps = 23.976
		@round = 10
		@extraopts = nil
		@input = false
		@sound = "-oac copy"
		@height = 0
		@width = 0
		@aids = Array.new
		@sids = 0
	end

	def execute(command)
		commandline(command)
		system(command) if @run
		question("Continue? ...")
	end

	def error(message)
		puts("\n#{LIGHT_RED}#{message}#{NO_COLOR}")
	end

	def commandline(command)
		puts("\n#{YELLOW}#{command}#{NO_COLOR}")
	end

	def info(message)
		puts("\n#{GREEN}#{message}#{NO_COLOR}")
	end

	def question(message)
		if @input
			puts "#{LIGHT_BLUE}#{message}#{NO_COLOR}"
			if "" != gets.chomp.strip
				exit(0)
			end 
		end
	end

	def get_info()
		unless File.exist?("settings.rb")
			line = nil
			commandline("mplayer -ss 600 -vo null -ao null -identify " + 
				"-frames 101 -vf cropdetect #{dev}")
			IO.popen("mplayer -ss 3600 -ao null -identify -frames 101" + 
				" -vf cropdetect #{dev}") {|io|
				line = io.read
			}

			@crop = line.scan(/\(-vf crop=.*?\)/)
			@crop = crop[crop.length - 1].gsub(/(.*\(-vf crop=)|(\).*)/, '').chomp
			sline = line.scan(/[0-9x]*\d => \d[0-9x]*/)[0]
			taids = line.scan(/.*AID.*/)
			alangs = line.scan(/.*AID.*/).each {|s| s.gsub!(/.*=/, '')}.uniq
			@sids = line.scan(/.*SID.*/).length
			alangs.each do |alang|
				i = 0
				while i < taids.length && !(/#{alang}/ =~ taids[i])
					i = i + 1
				end
				@aids.push(taids[i].gsub(/(ID_AID_)|(_.*)/, ''))
			end
			@width = crop.split(':')[0].to_i
			@height = crop.split(':')[1].to_i
			a = sline.gsub(/ => /, 'x').split('x')
			h = (a[1].to_f/a[0].to_f)*(a[2].to_f/a[3].to_f)
			if h > 1
				@height = (@height/h).round
			else
				@width = (@width*h).round
			end
			@scale="#{@width}:#{@height}"
			info("#{@scale} #{@crop} [#{@aids.join(', ')}] #{@sids}")
			settings = File.new("settings.rb", "w")
			settings.puts("class Encode")
			settings.puts("\tdef load_info")
			settings.puts("\t\t@height = #{@height}")
			settings.puts("\t\t@width = #{@width}")
			settings.puts("\t\t@scale = \"#{@scale}\"")
			settings.puts("\t\t@crop = \"#{@crop}\"")
			settings.puts("\t\t@aids = [#{@aids.join(', ')}]")
			settings.puts("\t\t@sids = #{@sids}")
			settings.puts("\tend")
			settings.puts("end")
			settings.close
			question("Continue? ...")
		else
			load "settings.rb"
			load_info
			info("#{@scale} #{@crop} [#{@aids.join(', ')}] #{@sids}")
		end
	end

	def load_vob()
		unless File.exist?("temp.vob")
			execute("mplayer #{@dev} -dumpstream -dumpfile temp.vob")
		end
		@dev = 'temp.vob'
	end

	def calc_vbitrate()
		# Calculate the video bitrate, round to nearest @round
		@vbitrate = (@bpp*@fps*@height*@width/(1000*@round)).round*@round
		info("vbitrate = #{@vbitrate}")
		#settings = File.new("settings.rb", "a")
		#settings.puts("vbitrate = #{@vbitrate}")
		#settings.close
	end

	def make_frameno()
		unless File.exist?("frameno.avi")
			execute("mencoder -quiet #{@dev} -ovc frameno -o frameno.avi " + 
				"-oac twolame -twolameopts br=32 -vf filmdint " +
				"-fps 30000/1001 -ofps 24000/1001")
		end
	end

	def make_ogg(aid)
		unless File.exist?("audio#{aid}.ogg")
			execute("mkfifo apipe ; " +
					"oggenc --quiet -q#{@aquality} -oaudio#{aid}.ogg apipe& " +
					" mplayer #{@dev} -hardframedrop -aid #{aid} -vc dummy" +
					" -vo null -af volnorm -ao pcm:file=apipe ; " +
					"rm -f apipe")
		end
	end

	def make_lavc_2pass()
		unless File.exist?("divx2pass.log")
			execute("mencoder #{@dev} -vf crop=#{@crop},scale=#{@scale}" + 
			",harddup,filmdint -fps 30000/1001 -ofps 24000/1001 " + 
			"-ffourcc XVID -o /dev/null -ovc lavc -lavcopts vcodec=mpeg4:" + 
			"vbitrate=#{@vbitrate}:mbd=2:v4mv:dia=4:mpeg_quant:" + 
			"vpass=1:turbo #{@sound} #{@extraopts} -quiet")
		end
		unless File.exist?("video.avi")
			execute("mencoder #{@dev} -vf crop=#{@crop},scale=#{@scale}" +
			",harddup,filmdint -fps 30000/1001 -ofps 24000/1001 " + 
			"-ffourcc XVID -o video.avi -ovc lavc -lavcopts vcodec=mpeg4:" +
			"vbitrate=#{@vbitrate}:mbd=2:v4mv:dia=4:mpeg_quant:" + 
			"vpass=2 #{@sound} #{@extraopts} -quiet")
		end
	end

	def make_xvid_2pass()
		execute("mencoder #{dev} -vf " +
			"crop=#{crop},scale=#{scale},harddup -ffourcc XVID" + 
			" -o /dev/null -ovc xvidenc -xvidencopts pass=1:bitrate=#{vbitrate}:" +
			"me_quality=6:quant_type=mpeg -nosound -fps 24000/1001")
		execute("mencoder #{dev}  -vf " +
			"crop=#{crop},scale=#{scale},harddup -ffourcc XVID" + 
			" -o video.avi -ovc xvidenc -xvidencopts pass=2:bitrate=#{vbitrate}:" +
			"me_quality=6:quant_type=mpeg -nosound -fps 24000/1001")
	end

	def make_ogm()
		info("creating ogm: syncing audio and video")
		line = ""
		IO.popen("mencoder video.avi -ovc copy -oac copy -o /dev/null") do |io|
			line = io.read
		end
		list = line.scan(/.*Video stream.*/)
		vidlength = (list[list.length - 1].gsub(/ secs.*/, "").gsub(/.* /, "").to_f*1000).to_i

		line = ""
		IO.popen("ogginfo audio*.ogg") do |io|
			line = io.read
		end
		list = line.scan(/.*Playback length.*/)
		min = list[list.length - 1].gsub(/.* /, "").gsub(/m.*/, "").to_i
		sec = list[list.length - 1].gsub(/.*m:/, "").gsub(/s/, "").to_i
		audlength = ((min*60 + sec)*1000).to_i
		#execute("ogmmerge -o #{@name}.ogm -A video.avi -s 0,#{vidlength}/#{audlength} audio*.ogg")
		execute("ogmmerge -o #{@name}.ogm -A video.avi audio*.ogg")
	end
end

opts = GetoptLong.new(
		['--help', '-h', GetoptLong::OPTIONAL_ARGUMENT],
		['--name', '-n', GetoptLong::REQUIRED_ARGUMENT],
		['--dev', '-d', GetoptLong::REQUIRED_ARGUMENT],
		['--vcodec', '-v', GetoptLong::REQUIRED_ARGUMENT],
		['--acodec', '-a', GetoptLong::REQUIRED_ARGUMENT],
		['--bpp', '-b', GetoptLong::REQUIRED_ARGUMENT],
		['--fps', '-f', GetoptLong::REQUIRED_ARGUMENT],
		['--aquality', '-q', GetoptLong::REQUIRED_ARGUMENT],
		['--crop', '-c', GetoptLong::REQUIRED_ARGUMENT],
		['--extraopts', '-e', GetoptLong::REQUIRED_ARGUMENT],
		['--test', '-t', GetoptLong::NO_ARGUMENT],
		['--input', '-i', GetoptLong::NO_ARGUMENT]
					 )

# Default values go here. The crop parameter will be detected if not specified


encoder = Encode.new()

opts.each do |opt, arg|
	case opt
	when '--help'
		case arg
		when ''
			RDoc::usage
		when 'u'
			RDoc::usage('Usage')
		when 'a'
			RDoc::usage('Author')
		when /l|c/
			RDoc::usage('Copyright')
		end
	when '--dev'
		encoder.dev = arg
	when '--bpp'
		encoder.bpp = arg.to_f
	when '--name'
		encoder.name = arg
	when '--acodec'
		encoder.acodec = arg
	when '--vcodec'
		encoder.vcodec = arg
	when '--crop'
		encoder.crop = arg
	when '--fps'
		encoder.fps = arg.to_f
	when '--extraopts'
		encoder.extraopts = arg
	when '--input'
		encoder.input = true
	when '--test'
		encoder.run = false
	end
end


if encoder.crop == nil
	encoder.get_info()
end

# Rip the source to a temporary file if it is a dvd. This speeds up later
# processing and removes the 'switching framerate' problems
if /dvd/ =~ encoder.dev
	encoder.load_vob()
end

encoder.calc_vbitrate()

# Encode audio
encoder.make_frameno()
encoder.aids.each do |aid|
	encoder.make_ogg(aid)
end

if 'lavc' == encoder.vcodec
	encoder.make_lavc_2pass
elsif 'xvid' == vcodec
	encoder.make_xvid_2pass
else
	error("Error: unknown video codec.")
end

encoder.make_ogm

# Cleanup
#if 'temp.vob' == dev
#	puts("#{LIGHT_RED}rm -f temp.vob#{NO_COLOR}")
#	execute("rm -f temp.vob")
#end
#puts("#{LIGHT_RED}rm -f video.avi audio.ogg divx2pass.log frameno.avi#{NO_COLOR}")
#execute("rm -f video.avi audio.ogg divx2pass.log frameno.avi")
