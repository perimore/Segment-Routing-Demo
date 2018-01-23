# Segment-Routing-Demo
This Vagrant project should allow you to deploy a simple segment routing topology with a controller to get to grips with the configuration involved. Included are 6 Arista vEOS VMs, an Ubuntu 14 VM running Exabgp and a nice graphical controller courtesy of @russellkelly.

**References**
- [Vagrant](https://www.vagrantup.com/)
- [Arista vEOS](https://eos.arista.com/veos-running-eos-in-a-vm/)
- [Exabgp](https://github.com/Exa-Networks/exabgp)
- [russellkelly's controller](https://github.com/russellkelly/SR_Demo_Repo)

## Requirements
- Vagrant
- VirtualBox
- Around 9GB of RAM when running in a MacOS environment. 

You may find lower memory utilisation on Windows or Linux due to support of memory balooning. This is a known limitation on Mac when using virtualised environments, at least with VirtualBox.

## Pre-Installation Steps
After installing Vagrant and VirtualBox are installed, we need to add the vEOS virtualbox image to Vagrant. Download the following image from https://www.arista.com/en/support/software-download (user registration required):


```
vEOS-lab/4.20/vEOS-lab-4.20.1F-virtualbox.box
```
Change directory to the download location and run the following:
```
vagrant box add vEOS-lab-4.20.1F-virtualbox.box
```
The box should now be listed as available in Vagrant:
```
[sean@Seans-MacBook-Pro] Segment-Routing-Demo $ vagrant box list
vEOS-lab-4.20.1F       (virtualbox, 0)
```
Note that Ubuntu doesn't need to added, it will be automatically found by Vagrant.

## Installation
Providing the vEOS box has been successfully added to Vagrant, we can now go ahead and start building the topology.
```
git clone https://github.com/perimore/Segment-Routing-Demo.git
cd Segment-Routing-Demo
vagrant up
```

This will now build the vEOS devices and controller. When finished, log into the devices using:
```
vagrant ssh controller
vagrant ssh bb1
vagrant ssh bb2
vagrant ssh bb3
vagrant ssh bb4
vagrant ssh bb5
vagrant ssh bb6
```
### vEOS CLI Access
```
vagrant ssh bb1
...
Arista Networks EOS shell

-bash-4.3# FastCli

bb1.16:58:37>en
bb1.16:58:38#
```
No configuration changes should need to be made.

### Controller Access
To use the controller we need to start Exabgp and the controller script. Open two ssh sessions and start the following in each:
```
Session 1:
cd SR_Demo_Repo
exabgp srdemo.conf

Session 2:
SR_Demo_Repo
./sr_demo.py -a 1.1.1.1 -u admin -p admin
```
The GUI can now be accessed here as port 5001 of the controller vm has been forwarded to 5002 on your local system:
http://localhost:5002/

## Controller Operation
Once up and running an LU tunnel can be signalled to the bb1 vEOS device. Use the following to push a FEC path and service prefix to bb6:

**Tunnel FEC**
- Dest FEC: 6.6.6.66 (Lo1 on bb6) 
- Dest FEC NH: 12.0.0.2 (NH of bb2)
- Select Primary to push the path to bb1
- **Click the nodes in the topology diagram to chose the path taken. I.e. bb5 and bb6.**

**Service Prefix**
- Dest Prefix: 9.9.9.9/32 (can be any prefix not already used)
- Dest Next hop: 6.6.6.66 (NH of the tunnel destination as above)

Note that vEOS does not support data path forwarding of traffic over MPLS. Therefore this is just a control plane test. Once pushed, the label path and service prefix can be seen installed on bb1:

```
bb1.17:30:13#show ip bgp
BGP routing table information for VRF default
Router identifier 1.1.1.1, local AS number 64512
Route status codes: s - suppressed, * - valid, > - active, # - not installed, E - ECMP head, e - ECMP
                    S - Stale, c - Contributing to ECMP, b - backup, L - labeled-unicast
Origin codes: i - IGP, e - EGP, ? - incomplete
AS Path Attributes: Or-ID - Originator ID, C-LST - Cluster List, LL Nexthop - Link Local Nexthop

        Network                Next Hop              Metric  LocPref Weight  Path
 * #  L 6.6.6.66/32            12.0.0.2              0       100     0       i
 * >    9.9.9.9/32             6.6.6.66              0       100     0       i


bb1.17:30:10#show ip bgp detail
BGP routing table information for VRF default
Router identifier 1.1.1.1, local AS number 64512
BGP routing table entry for 6.6.6.66/32
 Paths: 1 available
  Local
    12.0.0.2 labels [ 800004 800005 800006 ] from 10.10.10.10 (10.10.10.10)
      Origin IGP, metric 0, localpref 100, IGP metric 1, weight 0, received 00:00:12 ago, valid, internal, not installed (better AD route present)
      Rx path id: 0x0
      Rx SAFI: Labels
      Tunnel RIB eligible
BGP routing table entry for 9.9.9.9/32
 Paths: 1 available
  Local
    6.6.6.66 from 10.10.10.10 (10.10.10.10)
      Origin IGP, metric 0, localpref 100, IGP metric 0, weight 0, received 00:00:12 ago, valid, internal, best
      Rx path id: 0x0
      Rx SAFI: Unicast
      
      
bb1.17:30:56#show mpls tunnel fib
   Tunnel Type         Index       Endpoint           Nexthop        Interface      Labels
------------------- ----------- ------------------ -------------- ----------------- -----------------
...
   BGP LU              1           6.6.6.66/32        12.0.0.2       'Ethernet1'    [ 800004 800005 800006 ]
   
bb1.17:33:10#show mpls segment-routing bindings
1.1.1.1/32
   Local binding:  Label: imp-null
   Remote binding: Peer ID: 0002.0002.0002, Label: 800001
   Remote binding: Peer ID: 0003.0003.0003, Label: 800001
2.2.2.2/32
   Local binding:  Label: 800002
   Remote binding: Peer ID: 0002.0002.0002, Label: imp-null
   Remote binding: Peer ID: 0003.0003.0003, Label: 800002
3.3.3.3/32
   Local binding:  Label: 800003
   Remote binding: Peer ID: 0002.0002.0002, Label: 800003
   Remote binding: Peer ID: 0003.0003.0003, Label: imp-null
4.4.4.4/32
   Local binding:  Label: 800004
   Remote binding: Peer ID: 0002.0002.0002, Label: 800004
   Remote binding: Peer ID: 0003.0003.0003, Label: 800004
5.5.5.5/32
   Local binding:  Label: 800005
   Remote binding: Peer ID: 0002.0002.0002, Label: 800005
   Remote binding: Peer ID: 0003.0003.0003, Label: 800005
6.6.6.6/32
   Local binding:  Label: 800006
   Remote binding: Peer ID: 0002.0002.0002, Label: 800006
   Remote binding: Peer ID: 0003.0003.0003, Label: 800006

bb1.17:31:02#show ip route 9.9.9.9/32

VRF: default
Codes: C - connected, S - static, K - kernel,
       O - OSPF, IA - OSPF inter area, E1 - OSPF external type 1,
       E2 - OSPF external type 2, N1 - OSPF NSSA external type 1,
       N2 - OSPF NSSA external type2, B I - iBGP, B E - eBGP,
       R - RIP, I L1 - IS-IS level 1, I L2 - IS-IS level 2,
       O3 - OSPFv3, A B - BGP Aggregate, A O - OSPF Summary,
       NG - Nexthop Group Static Route, V - VXLAN Control Service,
       DH - Dhcp client installed default route

 B I    9.9.9.9/32 [200/0] via 12.0.0.2, Ethernet1 label **800004 800005 800006**

```




