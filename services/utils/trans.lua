local trans = {}

function trans.uid_agent(uid)
	return string.format(".agent%s", tostring(uid))
end

return trans