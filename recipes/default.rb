#
# Cookbook Name:: t3-base
# Recipe:: default
#
# Copyright 2011, TYPO3 Association
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Typo3::Base::Recipe)
::Chef::Recipe.send(:include, Typo3::Base::Node)

packages = [
  'bc',
  'curl',
  'htop',
  'iftop',
  'iotop',
  'lsb-release',
  'lynx',
  'mc',
  'nano',
  'tcpdump',
  'telnet',
  'tig',
  'traceroute',
  'wget',
  'whois'
]

case node[:platform]
  when "debian", "ubuntu"
    packages.each do |pkg|
      package pkg do
        action :upgrade
    end
  end
end


#######################
# Physical and Virtualized host
#######################

include_recipe "t3-base::_physical" if physical?
# not yet needed
# include_recipe "t3-base::_virtualized" if virtualized?

#######################
# Virtualization in use (either host or guest)
#######################

if virtualization?
  Chef::Log.debug("Virtualization detected (using #{node[:virtualization][:system]})")
  # automatically include the cookbook for the used virtualization type (e.g. openvz, vmware, vbox)
  include_if_available "#{node[:virtualization][:system]}::default"
end




include_recipe "t3-base::_postfix"
include_recipe "t3-base::squeeze-lts"

include_recipe "chef_handler"
include_recipe "locales"
include_recipe "openssh"
include_recipe "git"
include_recipe "etckeeper"
include_recipe "rsync"
include_recipe "screen"
include_recipe "ohmyzsh"
