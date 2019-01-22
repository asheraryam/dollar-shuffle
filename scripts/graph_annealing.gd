extends Node

# This class implements the simulated annealing algorithm for graph drawing
# described in Davidson and Harel's paper, "Drawing Graphs Nicely"
# https://dl.acm.org/citation.cfm?id=234538
# https://en.wikipedia.org/wiki/Simulated_annealing

# Constants

# This normalizing factor defines the importance of nodes being clustered 
# together, reducing distances between them.  It is lambda_1 in the paper.
const l1 = 1.0
# This normalizing factor defines how much nodes are pushed away from the edges
# of the drawing plane.  It is lambda_2 in the paper.
const l2 = 1.0
# This normalzing factor penalizes long edges between nodes.  It's lambda_3 in
# the paper.
const l3 = 1.0
# This normalizing factor penalizes close and crossed edges.  It's lambda_4 in
# the paper.
const l4 = 1.0
# The max number of trials to run before updating global temperature
const trials = 30
# The cooling rate for global temperature
const d_temp = 0.85
# The temperature threshold for stopping
const lim_temp = 0.0002
# The scaling factor used to ajdust the exponential probability function,
# represented by k in the paper and Boltzmann's constant in reality
const prob_const = 1.0

# Functions

# Simulated annealing function -- randomly move nodes over time to reduce cost
# function of whole graph
static func annealing(graph):
	# Start by randomly distributing all nodes
	for node in graph.keys():
		graph[node]["loc"] = [randf(), randf()]
	# Define a starting "temperature", which limits how far nodes can move 
	var temp = 0.35
	# Calculate current cost of whole system
	var cost_current = cost(graph)
	# While temp is above stopping threshold...
	while temp > lim_temp:
		# For the predefined number of trials...
		for index in range(trials):
			# Create a "candidate" graph and pick one random node to modify
			var graph_new = graph.duplicate()
			var node = str(randi()%len(graph))
			var loc = Vector2(graph[node]["loc"][0], graph[node]["loc"][1])
			# Move that node by taking a vector with temp length, rotating it around the
			# origin by a random angle (up to 2Pi), then adding it to the original loc
			var loc_new = Vector2(0.0, temp).rotated(randf()*2*PI) + loc
			# Make sure new location is inside bounding box
			loc_new.x = clamp(loc_new.x, 0.1, 0.9)
			loc_new.y = clamp(loc_new.y, 0.1, 0.9)
			# Save new location in candidate graph
			graph_new[node]["loc"] = [loc_new.x, loc_new.y]
			# Calculate the probability of new layout replacing old one.  If new layout
			# has lower cost, replacement is guaranteed
			var cost_new = cost(graph_new)
			var prob = exp(-(cost_new - cost_current) * prob_const / temp)
			print("Old, new, prob: %.2f, %.2f, %s" % [cost_current, cost_new, str(prob)])
			if randf() < prob:
				graph = graph_new
				cost_current = cost_new
		# Reduce temperature at a predefined rate
		temp *= d_temp
	return graph

# Cost function -- measure of how "good" the current layout is
static func cost(graph):
	# Total cost of graph
	var total = 0
	# For each node in the graph...
	for node in graph.keys():
		# Get location of current node
		var node_loc = Vector2(graph[node]["loc"][0], graph[node]["loc"][1])

		# NODE DISTRIBUTION 
		# For each pair of nodes in graph...
		var other_nodes = graph.keys()
		other_nodes.erase(node)
		for pair in other_nodes:
			# Add the square inverse of nodes' distance
			# Small distance means high cost
			var pair_loc = Vector2(graph[pair]["loc"][0], graph[pair]["loc"][1])
			if node_loc.distance_squared_to(pair_loc) == 0:
				total += INF
			else:
				total += l1 / node_loc.distance_squared_to(pair_loc)
		
		# BORDER DISTANCE
		# Calculate distance squared to top, bottom, left, and right edges
		var t = node_loc.distance_squared_to(Vector2(node_loc.x, 0))
		var b = node_loc.distance_squared_to(Vector2(node_loc.x, 1))
		var l = node_loc.distance_squared_to(Vector2(0, node_loc.y))
		var r = node_loc.distance_squared_to(Vector2(1, node_loc.y))
		# Add inverses of these vars to total, scaled by l2
		# Small distances mean high cost
		total += l2 * (1.0/t + 1.0/b + 1.0/l + 1.0/r)
		
		# EDGE LENGTHS
		# For each connection that node has...
		for conn in graph[node]["conns"]:
			# Add the square distance between the connected nodes
			# Large distances mean high cost
			var conn_loc = Vector2(graph[str(conn)]["loc"][0], graph[str(conn)]["loc"][1])
			total += l3 * node_loc.distance_squared_to(conn_loc)
		
		# NODE-EDGE DISTANCES
		# TODO: Implement this section
	return total
