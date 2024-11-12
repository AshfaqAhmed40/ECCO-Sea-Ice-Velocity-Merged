import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.path as mpath
import numpy as np

def plot_arctic(data_list, x_coords, y_coords, titles=None, cmaps=None, 
                vmin=None, vmax=None, colorbar_labels=None,
                nrows=1, ncols=2, figsize=(12, 6)):
    """
    Plot multiple variables on a polar stereographic projection in a flexible subplot layout.

    Parameters:
    - data_list: list of xarray.DataArray, variables to plot (e.g., Transfer Coefficient, Sea Ice Thickness)
    - x_coords: xarray.DataArray or np.array, x-coordinates for pcolormesh (e.g., longitude)
    - y_coords: xarray.DataArray or np.array, y-coordinates for pcolormesh (e.g., latitude)
    - titles: list of str, titles for each subplot
    - cmaps: list of str, colormaps for each variable
    - vmin: list of float, minimum color scale limits for each variable (optional)
    - vmax: list of float, maximum color scale limits for each variable (optional)
    - colorbar_labels: list of str, labels for each colorbar
    - nrows: int, number of rows in the subplot layout
    - ncols: int, number of columns in the subplot layout
    - figsize: tuple, size of the figure
    """
    
    # Set up flexible grid of subplots
    fig, axes = plt.subplots(nrows, ncols, figsize=figsize, 
                             subplot_kw={'projection': ccrs.NorthPolarStereo(true_scale_latitude=70)})
    
    # Ensure axes is 1D array for easy iteration, even if subplot layout is 1x1
    axes = np.atleast_1d(axes).ravel()

    # Loop over each subplot
    for ax, data, title, cmap, vmin_val, vmax_val, colorbar_label in zip(
            axes, data_list, titles or [None]*len(data_list), cmaps or ["viridis"]*len(data_list), 
            vmin or [None]*len(data_list), vmax or [None]*len(data_list), 
            colorbar_labels or [None]*len(data_list)):

        # Plot data on each subplot with pcolormesh
        mesh = ax.pcolormesh(x_coords, y_coords, data,
                             transform=ccrs.PlateCarree(),
                             shading='flat',
                             vmin=vmin_val,
                             vmax=vmax_val,
                             cmap=cmap)

        # Add land, gridlines, and coastlines
        ax.add_feature(cfeature.LAND, zorder=0, edgecolor='black')
        ax.gridlines(draw_labels=False)
        ax.coastlines()

        # Set extent to 67°N and above
        ax.set_extent([-180, 180, 67, 90], ccrs.PlateCarree())

        # Set circular boundary for polar projection
        theta = np.linspace(0, 2 * np.pi, 100)
        center, radius = [0.5, 0.5], 0.5
        verts = np.vstack([np.sin(theta), np.cos(theta)]).T
        circle = mpath.Path(verts * radius + center)
        ax.set_boundary(circle, transform=ax.transAxes)

        # Set title and colorbar
        if title:
            ax.set_title(title)
        cbar = plt.colorbar(mesh, ax=ax, orientation="vertical", pad=0.05, fraction=0.04)  
        # Adjust fraction for smaller colorbar
        if colorbar_label:
            cbar.set_label(colorbar_label, fontsize=9)  # Set label font size


    plt.tight_layout()
    plt.show()
