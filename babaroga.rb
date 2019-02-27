#!/usr/bin/env ruby
# encoding: UTF-8
require 'net/http'
require 'open-uri'
require 'json'
require 'socket'
require 'optparse'

class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
end
def banner()

puts "\n"
puts"██╗  ██╗ █████╗ ████████╗     ██████╗██╗      ██████╗ ██╗   ██╗██████╗ "
puts"██║  ██║██╔══██╗╚══██╔══╝    ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗"
puts"███████║███████║   ██║       ██║     ██║     ██║   ██║██║   ██║██║  ██║"
puts"██╔══██║██╔══██║   ██║       ██║     ██║     ██║   ██║██║   ██║██║  ██║"
puts"██║  ██║██║  ██║   ██║       ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝"
puts"╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝        ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ "



puts "Скрипта за пребарување во Cloudflare."

puts "\n"
end

options = {:bypass => nil, :massbypass => nil}
parser = OptionParser.new do|opts|

    opts.banner = "Пример: ruby hatcloud.rb -b <веб страната> или ruby hatcloud.rb --byp <веб страната>"
    opts.on('-b ','--byp ', 'Откривање на IP покрај CloudFlare', String)do |bypass|
    options[:bypass]=bypass;
    end

    opts.on('-o', '--out', 'Следна верзија.', String) do |massbypass|
        options[:massbypass]=massbypass

    end

    opts.on('-h', '--help', 'Помош') do
        banner()
        puts opts
        puts "Пример: ruby hatcloud.rb -b example.org или ruby hatcloud.rb --byp example.com"
        exit
    end
end

parser.parse!


banner()

if options[:bypass].nil?
    puts "Внеси веб страна -b или --byp"
else
	begin
	option = options[:bypass]
	payload = URI ("http://www.crimeflare.org:82/cgi-bin/cfsearch.cgi")
	request = Net::HTTP.post_form(payload, 'cfS' => options[:bypass])

	response =  request.body
	nscheck = /No working nameservers are registered/.match(response)
	if( !nscheck.nil? )
		puts "[-] Адресата не е валидна - Дали си сигурен дека страната е заштитена од CloudFlare?\n"
		exit
	end
	regex = /(\d*\.\d*\.\d*\.\d*)/.match(response)
	if( regex.nil? || regex == "" )
		puts "[-] Адресата не е валидна - Дали си сигурен дека страната е заштитена од CloudFlare?\n"
		exit
	end
rescue
	puts "ГРЕШКА !!!"
end
	ip_real = IPSocket.getaddress (options[:bypass])

	puts "[+] Анализа: #{option} ".green
	puts "[+] CloudFlare IP е #{ip_real} ".green
	puts "[+] Вистинската IP е #{regex}".green
	target = "http://ipinfo.io/#{regex}/json"
	url = URI(target).read
	json = JSON.parse(url)
	puts "[+] Hostname: ".green + json['hostname'].to_s
	puts "[+] Град: ".green  + json['city']
	puts "[+] Регион: ".green + json['country']
	puts "[+] Локација: ".green + json['loc']
	puts "[+] Организација:".green + json['org']

end
