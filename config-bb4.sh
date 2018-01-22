#!/usr/bin/env bash
FastCli -p 15 -c "configure
prompt %H.%D{%H:%M:%S}%P
alias agents bash ls -lrt /var/log/agents/
alias c bash clear
alias core bash ls -lrt /var/core/
alias d show interfaces description | grep -v 'not\|down'
alias log bash sudo tail -f /var/log/messages | grep -v -i xcvr
alias m show run section monitor
alias qt bash ls -lrt /var/log/qt/
alias senz show interface counter error | nz
alias shmc show int | awk '/^[A-Z]/ { intf = \$1 } /, address is/ { print intf, \$6 }'
alias snz show interface counter | nz
alias spd show port-channel %1 detail all
alias sqnz show interface counter queue | nz
alias srnz show interface counter rate | nz
alias top show proc top
!
no schedule tech-support
!
transceiver qsfp default-mode 4x10G
!
hostname bb4
!
spanning-tree mode mstp
!
aaa authorization exec default local
!
username vagrant privilege 15 role network-admin secret vagrant
!
vrf definition tenant-a
!
vrf definition tenant-b
!
interface Ethernet1
   no switchport
   ip address 24.0.0.4/24
   isis enable sr_instance
   isis network point-to-point
!
interface Ethernet2
   no switchport
   ip address 34.0.0.4/24
   isis enable sr_instance
   isis network point-to-point
!
interface Ethernet3
   no switchport
   ip address 45.0.0.4/24
   isis enable sr_instance
   isis network point-to-point
!
interface Ethernet4
   no switchport
   ip address 46.0.0.4/24
   isis enable sr_instance
   isis network point-to-point
!
interface Ethernet5
   no switchport
   ip address 46.0.1.4/24
   isis enable sr_instance
   isis network point-to-point
!
interface Loopback0
   ip address 4.4.4.4/32
   isis enable sr_instance
   node-segment ipv4 index 4
!
interface Loopback1
   shutdown
   ip address 22.22.22.22/32
   isis enable sr_instance
!
interface Loopback200
   ip address 4.4.4.200/32
   isis enable sr_instance
!
interface Management1
   ip address 10.0.2.15/24
!
ip routing
no ip routing vrf tenant-b
no ip routing vrf tenant-a
!
ip prefix-list LDP-FECs
   seq 1 permit 2.2.2.200/32
   seq 2 permit 1.1.1.200/32
   seq 3 permit 3.3.3.200/32
   seq 4 permit 4.4.4.200/32
   seq 5 permit 5.5.5.200/32
   seq 6 permit 6.6.6.200/32
!
mpls ip
!
mpls ldp
   router-id 4.4.4.4
   transport-address interface Loopback200
   fec filter prefix-list LDP-FECs
   no shutdown
!
mpls label range isis-sr 800000 4096
!
router isis sr_instance
   net 49.0001.0004.0004.0004.00
   is-type level-2
   log-adjacency-changes
   !
   address-family ipv4 unicast
   !
   segment-routing mpls
      router-id 4.4.4.4
      no shutdown
      prefix-segment 22.22.22.22/32 index 22
!
management api http-commands
   no shutdown
   protocol http
      no shutdown
!
end
copy running-config startup-config"
