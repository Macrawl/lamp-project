# Creating Multiple nodes in a vagrant Machine 

Vagrant can  define and control multiple guest machines, this is known as a "multi-machine" environment.

To create two nodes using vagrant, you have to define the VM's in the vagrantfile using  ```config.vm.define``` method call.

The primary machine will be the default machine used when a specific machine in a multi-machine environment is not specified.


## Creating two nodes in vagrant 

Node A = Master
Node B = Mlave

To specify a default machine, just mark it primary when defining it. Only one primary machine may be specified.

```config.vm.define "master", primary:true do |master|```

## NODE A

```
config.vm.define "master", primary:true do |master|
    master.vm.hostname = "master"
    master.vm.network  "private_network", type: "dhcp"
end
```

## NODE B

```
config.vm.define "slave", do |slave|
    slave.vm.hostname = "slave"
    slave.vm.network  "private_network", type: "dhcp"
end
```

## Controlling Multiple Machines

The moment more than one machine is defined within a Vagrantfile, then there is a slight variation in the use of various vagrant commands. 

Commands that only make sense to target a single machine, such as vagrant ssh, now require the name of the machine to control. Using the example above, you would say ```vagrant ssh master ``` or  ```vagrant ssh slave```

Other commands, such as vagrant up, operate on every machine by default. So if you ran vagrant up, Vagrant would bring up both the master and slave machine. You could also optionally be specific and say ```vagrant up master``` or ```vagrant up slave```.
