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
		var power: int = floor(log(abs(num)) / log(10))
		var dec_hundredths: int = floor((num / (10.0 ** power as float)) * 100)
		
		# Should be in the range [100, 1000)
		if dec_hundredths < 100:
			dec_hundredths *= 10
			power -= 1
		if dec_hundredths >= 1000:
			dec_hundredths /= 10
			power += 1
			
		if dec_hundredths >= 1000 or dec_hundredths < 100: breakpoint
		
		var pre_decimal: int = dec_hundredths / 100
		var post_decimal: int = dec_hundredths % 100
		
		if post_decimal == 0:
			# No useful post-decimal info, print as int
			return str("%de%d" % [pre_decimal, power])
		else:
			return str("%d.%de%d" % [pre_decimal, post_decimal, power])

func get_total_cost(cost: float, cost_ratio: float, count: int) -> float:
	return cost * ((cost_ratio ** count) - 1) / (cost_ratio - 1)

func exec_event(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
