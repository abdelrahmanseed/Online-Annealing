import networkx as nx
import numpy as np


def greedy_color_mod(graph, strategy):
    G = nx.from_numpy_array(np.array(graph))
    result = nx.coloring.greedy_color(G, strategy=strategy)

    # Create a list of length equal to number of nodes, with all values initialized to 0
    color_map = [0] * len(G.nodes)

    # Update the color_map with the color values from the result
    for node, color in result.items():
        color_map[node] = color + 1  # Add 1 to adjust for MATLAB's 1-based indexing

    return np.array(color_map)  # Convert the list to a numpy array before returning


if __name__ == '__main__':

    # uncomment below to run example directly here in python. It will override whatever MATLAB sends
    # graph = [
    #     [0, 1, 0, 0, 1, 0, 0, 0, 0, 0],
    #     [1, 0, 1, 0, 1, 0, 0, 0, 0, 0],
    #     [0, 1, 0, 1, 0, 0, 0, 1, 0, 0],
    #     [0, 0, 1, 0, 1, 1, 0, 0, 1, 0],
    #     [1, 1, 0, 1, 0, 0, 1, 0, 0, 0],
    #     [0, 0, 0, 1, 0, 0, 1, 0, 1, 0],
    #     [0, 0, 0, 0, 1, 1, 0, 1, 0, 1],
    #     [0, 0, 1, 0, 0, 0, 1, 0, 1, 0],
    #     [0, 0, 0, 1, 0, 1, 0, 1, 0, 1],
    #     [0, 0, 0, 0, 0, 0, 1, 0, 1, 0]
    # ]
    # strategy = 'DSATUR'

    colorMap = greedy_color_mod(graph, strategy)
    # print(colorMap)
