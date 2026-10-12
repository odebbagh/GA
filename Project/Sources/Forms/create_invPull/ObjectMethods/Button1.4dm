// OK of a stock correction (pull or put back) from Customer Service > Inventories
Case of 
	: (Num:C11(Form:C1466.invPull.qtyToPull)<=0)
		ALERT:C41("Enter a quantity greater than zero.")
	: (String:C10(Form:C1466.invPull.reason)="")
		ALERT:C41("Choose the reason of this correction.")
	: (String:C10(Form:C1466.invPull.pulledBy)="")
		ALERT:C41("Choose who performed it.")
	Else 
		ACCEPT:C269
End case 
