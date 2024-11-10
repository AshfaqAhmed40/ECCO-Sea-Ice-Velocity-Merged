# memory_utils.py

import pandas as pd
from pympler import asizeof
import sys
import gc
import warnings

def list_sorted_vars(global_vars, top_n=10):
    """
    Lists and sorts variables by memory usage.

    Parameters:
    - global_vars (dict): The globals() dictionary from the notebook.
    - top_n (int): Number of top variables to display.

    Returns:
    - pd.DataFrame: DataFrame containing variables and their sizes.
    """
    # Suppress specific UserWarnings from pympler's asizeof
    warnings.filterwarnings(
        "ignore",
        category=UserWarning,
        message="Iterating '<class 'traitlets.config.loader.Config'>': TypeError"
    )
    
    # Initialize a dictionary to hold variable names and their deep sizes
    var_sizes = {}
    
    # Iterate over a copy of globals() to prevent RuntimeError
    for var, val in list(global_vars.items()):
        # Optionally, exclude built-in variables and modules
        if not var.startswith('_') and not isinstance(val, type(sys)):
            try:
                size = asizeof.asizeof(val)
                var_sizes[var] = size
            except Exception:
                var_sizes[var] = 0  # Assign 0 if size can't be determined
    
    # Create a DataFrame from the dictionary
    df = pd.DataFrame(list(var_sizes.items()), columns=['Variable', 'Size (bytes)'])
    
    # Sort the DataFrame by size in descending order
    df_sorted = df.sort_values(by='Size (bytes)', ascending=False).reset_index(drop=True)
    
    # Display the top N variables by memory usage
    print(df_sorted.head(top_n))
    
    # Optional: Force garbage collection to free up memory
    gc.collect()
