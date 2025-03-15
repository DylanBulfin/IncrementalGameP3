extends Node


func format(num: float) -> String:
	const fstr: String = "%.2f"
	if is_nan(num) or is_inf(num):
		return str(num)
	elif num < 1000:
		var num_str: String = fstr % num
		if num_str.substr(len(num_str) - 2) == "00":
			# Show as integer
			return "%d" % num
		else:
			return num_str
	else:
		var power: float = floor(log(abs(num)) / log(10))
		var dec: float = num / (10 ** power)
		
		var dec_str: String = fstr % dec
		
		# Floating point arithmetic is gross
		if dec_str[0] == '0':
			# Less than 1, adjust
			power -= 1
			dec *= 10
		if len(dec_str) == 5:
			# Greater than 10, adjust
			power += 1
			dec /= 10
		
		# Update
		dec_str = fstr % dec
		
		if dec_str.substr(len(dec_str) - 2) == "00":
			# Show as integer
			return str("%d" % dec, "e%d" % power)
		else:
			return str(dec_str, "e%d" % power)

func get_total_cost(cost: float, cost_ratio: float, count: int) -> float:
	return cost * ((cost_ratio ** count) - 1) / (cost_ratio - 1)

func exec_event(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
