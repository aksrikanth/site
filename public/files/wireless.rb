#!/usr/bin/env ruby

# == Synopsis
# wireless : Start or stop the appropriate wireless network
#
# == Usage
#
# wireless [OPTION]
#
# -h, --help ::
#   show this help message
# -s, --start ::
#   start the wireless network (default)
# -p, --stop ::
#   stop the current connection
# -e, --essid ::
#   the ESSID of the network to connect to
# -k, --key ::
#   the key for a secured network
#
# == Author
#
# Srikanth K Agaram, University of California, Irvine
#
# == Copyright
#
# Copyright (c) 2007 Srikanth Agaram. Licenced under the GNU GPLv3

require 'getoptlong'
require 'rdoc/usage'

class Wireless
	NO_COLOR="\033[0m"
	GRAY="\033[1;30m"
	LIGHT_RED="\033[1;31m"
	GREEN="\033[01;32m"                                                                                                                                           
	YELLOW="\033[1;33m"
	LIGHT_BLUE="\033[1;34m"                                                                                                                                       
	LIGHT_GRAY="\033[0;37m"
	WHITE="\033[1;37m"

	attr_reader :essid, :key, :mode
	attr_writer :essid, :key, :mode

	def initialize(essid, key)
		@essid = essid
		@key = key
	end

	def inform(message)
		puts "\n#{GREEN}#{message}#{NO_COLOR}"
	end

	def commandline(command)
		puts "\n#{YELLOW}#{command}#{NO_COLOR}"
	end

	def question(message)
		if @input
			puts "#{LIGHT_BLUE}#{message}#{NO_COLOR}"
			if "" != gets.chomp.strip
				exit(0)
			end 
		end
	end

	def warning(message)
		puts "\n#{LIGHT_RED}Warning : #{message}#{NO_COLOR}"
	end

	def error(message)
		puts "\n#{LIGHT_RED}Error : #{message}#{NO_COLOR}"
	end

	def fatal_error(message, error_code)
		puts "\n#{LIGHT_RED}Fatal Error : #{message}#{NO_COLOR}"
		exit error_code
	end

	def start_daemon
		#Start the ipw daemon if not running
		inform "Checking for running ipw daemon"
		IO.popen "ps -el | grep -c ipw3945d" do |io|
			num = io.gets.to_i
			if num == 0
				inform "\tipw daemon not running. Starting ipw daemon..."
				system "/sbin/modprobe ipw3945"
				system "/etc/init.d/ipw3945d start"
			else
				inform "\tipw daemon running."
			end
		end
	end

	def get_network_list
		foundlist = Array.new

		# Load the list of active wireless networks
		inform "Finding active networks..."
		IO.popen "iwlist #{Settings['device']} scanning" do |io|
			line = io.gets
			while line != nil
				if /.*ESSID.*/ =~ line
					foundlist.push(line.gsub(/(.*:")|("$)/, '').chomp)
				end
				line = io.gets
			end
		end
		if foundlist.length == 0
			fatal_error("No active networks found. Aborting!", 1)
		end

		return foundlist
	end

	def load_settings
		inform "Loading known networks..."
		# Load the list of known wireless networks
		load '/etc/wireless.conf.rb'
	end

	def find_known_networks(foundlist)
		done = false
		foundlist.each do |found|
			if done != true
				KnownList.each do |essid, key|
					if found == essid
						inform "Found known network '#{essid}'"
						@essid = essid
						@key = key
						done = true
					end
				end
			end
		end

		if done == false
			warning "No known networks found."
			inform "Trying unknown network #{foundlist[0]}..."
			@essid = foundlist[0]
			@key = nil
		end
	end

	def up
		system("ifconfig #{Settings['device']} down")
		system("iwconfig #{Settings['device']} essid \"#{@essid}\"")
		if @key != nil
			system("iwconfig #{Settings['device']} key \"#{@key}\"")
		end
		system("dhclient -e #{Settings['device']}")
		system("cat /root/resolv.conf >> /etc/resolv.conf")
	end

	def down
		commandline "ifconfig #{Settings['device']} down"
		system("ifconfig #{Settings['device']} down")
	end

	def start
		load_settings
		start_daemon
		if (@essid == nil)
			list = get_network_list
			find_known_networks(list)
		end
		up
	end

	def stop
		load_settings
		down
	end
end

opts = GetoptLong.new(
		['--help', '-h', GetoptLong::OPTIONAL_ARGUMENT],
		['--start', '-s', GetoptLong::NO_ARGUMENT],
		['--stop', '-p', GetoptLong::NO_ARGUMENT],
		['--essid', '-e', GetoptLong::REQUIRED_ARGUMENT],
		['--key', '-k', GetoptLong::REQUIRED_ARGUMENT]
					 )

essid = nil
key = nil
mode = 'start'

wireless = Wireless.new(essid, key)

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
	when '--start'
		mode = 'start'
	when '--stop'
		mode = 'stop'
	when '--essid'
		wireless.essid = arg
	when '--key'
		wireless.key = arg
	end
end

if /start/ =~ mode
	wireless.start
elsif /stop/ =~ mode
	wireless.stop
end
