var $eTodo : cs:C1710.sfw_TodoEntity

SUSPEND TRANSACTION:C1385

$eTodo:=ds:C1482.sfw_Todo.new()
$eTodo.UUID:=Generate UUID:C1066
$eTodo.UUID_target:=Form:C1466.current_item.UUID
$eTodo.UUID_UserCreator:=cs:C1710.sfw_userManager.me.info.UUID
$eTodo.UUID_targetAssigned:=Form:C1466.UUID_targetAssigned
$eTodo.entryIdent:=Form:C1466.entry.ident
$eTodo.description:=Form:C1466.todoDescription
$eTodo.ID_level:=0
$eTodo.stmp:=cs:C1710.sfw_stmp.me.now()
$eTodo.deadlineStmp:=cs:C1710.sfw_stmp.me.build(Form:C1466.deadlineDate; Form:C1466.deadlineTime)
$eTodo.moreData:=New object:C1471
$info:=$eTodo.save()

cs:C1710.sfw_todoListManager.me.updateTodoList()

RESUME TRANSACTION:C1386

ACCEPT:C269