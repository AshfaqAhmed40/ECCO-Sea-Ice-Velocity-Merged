import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.path as mpath
import numpy as np

def plot_arctic(var1, var2, x_coords, y_coords, title_1="Variable 1", title_2="Variable 2", 
                cmap1="viridis", cmap2="viridis", 
                vmin1=None, vmax1=None,
                vmin2=None, vmax2=None):
    """
    Plot two variables on a polar stereographic projection in a 1x2 subplot layout.

    Parameters:
    - var1: xarray.DataArray, first variable to plot (e.g., Transfer Coefficient)
    - var2: xarray.DataArray, second variable to plot (e.g., Sea Ice Thickness)
    - x_coords: xarray.DataArray or np.array, x-coordinates for pcolormesh (e.g., longitude)
    - y_coords: xarray.DataArray or np.array, y-coordinates for pcolormesh (e.g., latitude)
    - title_1: str, title for the first subplot
    - title_2: str, title for the second subplot
    - cmap1: str, colormap for the first variable
    - cmap2: str, colormap for the second variable
    - vmax1: float, maximum color scale limit for the first variable (optional)
    - vmax2: float, maximum color scale limit for the second variable (optional)
    """
    
    # Set up a 1x2 grid of subplots
    fig, axes = plt.subplots(1, 2, figsize=(12, 6), 
                             subplot_kw={'projection': ccrs.NorthPolarStereo(true_scale_latitude=70)})

    # Define data, titles, colormaps, and vmin/vmax limits for each subplot
    data_list = [var1, var2]
    titles = [title_1, title_2]
    cmaps = [cmap1, cmap2]
    vmins = [vmin1, vmin2]
    vmaxs = [vmax1, vmax2]

    # Loop over each subplot
    for ax, data, title, cmap, vmin, vmax in zip(axes, data_list, titles, cmaps, vmins, vmaxs):
        # Plot data on each subplot with pcolormesh
        mesh = ax.pcolormesh(x_coords, y_coords, data,
                             transform=ccrs.PlateCarree(),
                             shading='flat',
                             vmin=vmin,
                             vmax=vmax,
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

        # Title and colorbar
        ax.set_title(title)
        plt.colorbar(mesh, ax=ax, orientation="vertical", pad=0.05, label=title)

    plt.tight_layout()
    plt.show()
