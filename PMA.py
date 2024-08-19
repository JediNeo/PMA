from tkinter.filedialog import askopenfilename
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import geopandas as gp
from shapely.geometry import Point
from mpl_toolkits.basemap import Basemap
import plotly


filename = askopenfilename()
dfState = pd.read_csv(filename)
#dfState['mission_time'] = pd.to_datetime(dfState['mission_time'])

dfGeo = pd.DataFrame(list(zip(dfState["longitude"], dfState["latitude"])))
geometry = [Point(xy) for xy in zip(dfState["longitude"], dfState["latitude"])]
crs = {'init': 'epsg:4326'}
geo_df = gp.GeoDataFrame(dfState, crs=crs, geometry=geometry)

#start_time = dfState['mission_time'].iloc[0]
#end_time = dfState['mission_time'].iloc[-1]
#total_time = dfState['mission_time'].iloc[-1] - dfState['mission_time'].iloc[0]
dfState['knots'] = dfState['estimated_velocity'] * 1.94384
dfState['depth_down'] = dfState['depth'] * -1

# llcrnrlat,llcrnrlon,urcrnrlat,urcrnrlon
# are the lat/lon values of the lower left and upper right corners
# of the map.
# resolution = 'c' means use crude resolution coastlines.
#m = Basemap(projection='cyl',llcrnrlat=-90,urcrnrlat=90,\
#            llcrnrlon=-180,urcrnrlon=180,resolution='c')
#m.drawcoastlines()
#m.fillcontinents(color='coral',lake_color='aqua')
# draw parallels and meridians.
#m.drawparallels(np.arange(-90.,91.,30.))
#m.drawmeridians(np.arange(-180.,181.,60.))
#m.drawmapboundary(fill_color='aqua') 
#plt.title("Equidistant Cylindrical Projection")

# setup Lambert Conformal basemap.
# set resolution=None to skip processing of boundary datasets.
#m = Basemap(width=120000,height=90000,projection='lcc',
#            resolution='f',lat_1=40.,lat_2=43,lat_0=41.6,lon_0=-71.3)
#m.bluemarble() 
# plot blue dot on Boulder, colorado and label it as such.
#lon, lat = dfGeo[0], dfGeo[1]
# convert to map projection coords. 
# Note that lon,lat can be scalars, lists or numpy arrays.
#xpt,ypt = m(lon,lat) 
# convert back to lat/lon
#lonpt, latpt = m(xpt,ypt,inverse=True)
#m.plot(xpt,ypt)  # plot a blue dot there
# put some text next to the dot, offset a little bit
# (the offset is in map projection coordinates)
#plt.show()

#dfState['latitude'].set_crs("EPSG:4326")
#dfState['longitude'].set_crs("EPSG:4326")
#dfState['depth_down'].plot()
#print(dfGeo)
#plt.plot(dfGeo[0], dfGeo[1])
dfState.plot(x='mission_time', y=["thruster_rpm", "thruster_rpm_goal", "knots"], secondary_y=['knots'], kind='line')
#  dfState[['thruster_rpm', 'thruster_rpm_goal']].plot(dfState['mission_time'])
plt.grid(True)
plt.show()