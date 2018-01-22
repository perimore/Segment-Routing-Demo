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
hostname bb1
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
   ip address 12.0.0.1/24
   isis enable sr_instance
   isis network point-to-point
!
interface Ethernet2
   no switchport
   ip address 13.0.0.1/24
   isis enable sr_instance
   isis network point-to-point
!
interface Ethernet3
   no switchport
   ip address 10.10.10.1/24
   isis enable sr_instance
   isis metric maximum
   isis network point-to-point
!
interface Loopback0
   ip address 1.1.1.1/32
   ipv6 address 2000:1:1:1::1/128
   isis enable sr_instance
   node-segment ipv4 index 1
!
interface Loopback1
   ip address 1.1.1.2/32
!
interface Loopback200
   ip address 1.1.1.200/32
   isis enable sr_instance
!
interface Management1
   ip address 10.0.2.15/24
!
ip routing
ip routing vrf tenant-b
ip routing vrf tenant-a
!
ip community-list standard match-remote-VNF permit 11:66
ip extcommunity-list standard vpn1extcomm permit rt 64512:11
!
ip prefix-list Controller-LAN
   seq 10 permit 10.10.10.0/24
!
ip prefix-list LDP-FECs
   seq 1 permit 2.2.2.200/32
   seq 2 permit 1.1.1.200/32
   seq 3 permit 3.3.3.200/32
   seq 4 permit 4.4.4.200/32
   seq 5 permit 5.5.5.200/32
   seq 6 permit 6.6.6.200/32
!
ip prefix-list bb1_lo0
   seq 10 permit 1.1.1.1/32
!
mpls ip
!
mpls ldp
  router-id 1.1.1.1
   transport-address interface Loopback200
   fec filter prefix-list LDP-FECs
   no shutdown
!
mpls label range isis-sr 800000 4096
!
class-map type qos match-any qos-class-map
   match ip access-group qos-acl
!
policy-map type qos qos-policy-map
   class qos-class-map
      set traffic-class 3
   !
   class class-default
!
route-map Redistribute-Statics permit 1
   match ip address prefix-list Controller-LAN
   set metric 240
!
route-map Route-MAP-TO-VNF1 permit 20
   match community match-remote-VNF
   set ip next-hop unchanged
!
route-map Route-MAP-TO-VNF1 permit 30
!
route-map SET-LOCAL-PREF permit 1
   set local-preference 150
!
route-map SR-NODE-LABEL permit 10
   description node label index for BB1-lo1
   set community 11:66
   set segment-index 11
!
route-map Set-vpn1-comm permit 10
   match extcommunity vpn1extcomm
!
router bgp 64512
   router-id 1.1.1.1
   maximum-paths 128
   neighbor 6.6.6.6 remote-as 64512
   neighbor 6.6.6.6 update-source Loopback0
   neighbor 6.6.6.6 send-community
   neighbor 6.6.6.6 maximum-routes 12000
   neighbor 10.10.10.10 remote-as 64512
   neighbor 10.10.10.10 update-source Loopback0
   neighbor 10.10.10.10 maximum-routes 12000
   !
   address-family ipv4 labeled-unicast
      neighbor 6.6.6.6 activate
      neighbor 6.6.6.6 next-hop-self source-interface Loopback0
      neighbor 10.10.10.10 activate
      neighbor 10.10.10.10 route-map SET-LOCAL-PREF in
      network 1.1.1.2/32 route-map SR-NODE-LABEL
!
router isis sr_instance
   net 49.0001.0001.0001.0001.00
   is-type level-2
   log-adjacency-changes
   redistribute static route-map Redistribute-Statics
   !
   address-family ipv4 unicast
   !
   segment-routing mpls
      router-id 1.1.1.1
      no shutdown
!
management api http-commands
   no shutdown
   protocol http
      no shutdown
!
end
copy running-config startup-config"
