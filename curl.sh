curl -u rt-api:secret_password -i -X POST -H Content-Type:application/json localhost:3000/icinga/service_notification -d '
{
	"problem_id": "123",
	"last_problem_id": "0",
	"hostname": "text.example.com",
	"state": "CRITICAL",
	"state_type": "HARD",
	"description": "DISK",
	"output": "Disk is full!"
}
'

curl -u rt-api:secret_password -i -X POST -H Content-Type:application/json localhost:3000/icinga/host_notification -d '
{
	"problem_id": "78",
	"last_problem_id": "0",
	"hostname": "text.example.com",
	"state": "CRITICAL",
	"state_type": "HARD",
	"output": "Disk is full!"
}
'
