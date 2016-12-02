# Created by AlexALX (c) 2011-2014
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Address list usage
@inputs Refresh SG:wirelink
@outputs
@persist AddressList:table
@trigger

if (Refresh==1) {
    AddressList = SG:stargateAddressList()

    # print all addresses in chat and console
    for(I=0,AddressList:count()-1) {
        V = AddressList[I,array]
        Address = V[1,string] # Get address
        Name = V[2,string] # Get name
        Blocked = V[3,number] # Get blocked
        # Printing
        if (Blocked==1) {
            print("BLOCKED! Address - " + Address + " Name - " + Name)
        } else {
            print("Address - " + Address + " Name - " + Name)
        }
    }

}