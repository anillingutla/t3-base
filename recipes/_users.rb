include_recipe "sudo"

# With kitchen-docker 2.6.0, we cannot manage the /etc/sudoers file anymore.
# Therefore, we have to give the kitchen user back its sudo rights.
# See https://github.com/test-kitchen/kitchen-docker/issues/246
#
# Additionally, it's the "kitchen" user with Debian, the "vagrant" user with Ubuntu.
%w(kitchen vagrant).each do |user|
  sudo user do
    user user
    nopasswd true
    not_if { ENV['TEST_KITCHEN'].nil? }
  end
end

# check if the "users" data bag exists. if not, just skip the
# remainder of this recipe.
unless users_databag_exists?
  Chef::Log.warn("Data bag \"#{users_databag_name}\" doesn't exist")
  return
end

##############
# sysadmins
##############

# automatically add all users in the sysadmin group
include_recipe "users::sysadmins"

# Permit additional "sysadmin" tasks which can be run without password
sudo "sysadmins" do
  group "sysadmin"
  nopasswd true
  command_aliases [
                    { name: 'APT_GET',     command_list: ['/usr/bin/apt-get'] },
                    { name: 'CHEF_CLIENT', command_list: ['/usr/bin/chef-client'] },
                    { name: 'SERVICE',     command_list: ['/usr/sbin/service'] }
                  ]
  commands ['APT_GET', 'CHEF_CLIENT', 'SERVICE']
end

##############
# users defined for this node
##############

node_attribute = "fqdn"
log "Searching for users associated with node #{node[node_attribute]}"
begin
  users = search(users_databag_name, "nodes:#{node[node_attribute]}")
rescue Net::HTTPServerException
  Chef::Log.warn "Searching for users in the 'users' databag failed, search for users associated with node '#{node[node_attribute]}'"
  users = {}
end

users.each do |u|
  node_options = u['nodes'][node[node_attribute]]
  Chef::Log.info "Got node options: #{node_options}"
  if u['action'] == "remove" || node_options['action'] == "remove"
    user u['username'] ||= u['id'] do
      action :remove
    end
  else
    security_group = []
    u['username'] ||= u['id']
    security_group << u['username']

    home_dir = "/home/#{u['username']}"

    # The user block will fail if the group does not yet exist.
    # See the -g option limitations in man 8 useradd for an explanation.
    # This should correct that without breaking functionality.
    group u['username'] do
      gid u['gid']
      only_if { u['gid'] && u['gid'].is_a?(Numeric) }
    end

    # Create user object.
    user u['username'] do
      uid u['uid'] if u['uid']
      gid u['gid'] if u['gid']
      shell u['shell']
      comment u['comment']
      password u['password'] if u['password']
      supports manage_home: true
      home home_dir
      action u['action'] if u['action']
    end

    directory home_dir do
      owner u['username']
      group u['gid'] if u['gid']
      mode '0755'
    end

    # ssh key management
    directory "#{home_dir}/.ssh" do
      owner u['username']
      group u['gid'] if u['gid']
      mode '0700'
    end

    file "#{home_dir}/.ssh/authorized_keys" do
      content Array(u['ssh_keys']).join("\n")
      owner u['username']
      group u['gid'] if u['gid']
      mode '0600'
      only_if { u['ssh_keys'] }
    end

    # sudo management
    if node_options['sudo'] == "true"
      sudo u['username'] do
        nopasswd true
        user u['username']
      end
    else
      sudo u['username'] do
        action :remove
      end
    end
  end
end
