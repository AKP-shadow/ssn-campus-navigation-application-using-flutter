import csv
import json
 
 
# Function to convert a CSV to JSON
# Takes the file paths as arguments
def make_json(csvFilePath, jsonFilePath):
     
    # create a dictionary
    data = {}
    second_data = {}
    # Open a csv reader called DictReader
    with open(csvFilePath, encoding='utf-8') as csvf:
        csvReader = csv.DictReader(csvf)
         
        # Convert each row into a dictionary
        # and add it to data
        for rows in csvReader:
             
            # Assuming a column named 'No' to
            # be the primary key
            key = rows['point_no']
            data[key] = rows
            key1 = rows['label'].split(',')[0]
            if rows['is_marker'] == '1':
                second_data[key1] = key
    # Open a json writer, and use the json.dumps()
    # function to dump data
    with open(jsonFilePath, 'w', encoding='utf-8') as jsonf:
        jsonf.write(json.dumps(data, indent=4))
    with open(jsonFilePath1, 'w', encoding='utf-8') as jsonf:
        jsonf.write(json.dumps(second_data, indent=4))        
# Driver Code
 
# Decide the two file paths according to your
# computer system
csvFilePath = './data/route.csv'
jsonFilePath = './data/all_points.json'
jsonFilePath1 = './data/addall_points.json'
 
# Call the make_json function
make_json(csvFilePath, jsonFilePath)


# routes = get_route_dict("all_points.json")
# for markers in routes:
#     lat1,lng1 = routes[markers]['lat_lng'].split(',') 
#     print(markers)
#     for dest in routes[markers]['adj'].split(','):
#         lat2,lng2 =   routes[dest]['lat_lng'].split(',')
#         print(lng1,lat2)
#         folium.PolyLine(locations = [(lat1,lng1), (lat2, lng2)],
#             line_opacity = 0.5, color='green').add_to(my_map4)
# my_map4.save("my_map4.html")

# print(routes['2']['lat_lng'])
# print(distance((12.751617010495364, 80.20367432693531),(12.752208238293772, 80.20361531835628)) -distance((11.751617010495364, 80.20367432693531),(12.752208238293772, 80.20361531835628)) )
# marker_location = dict()
# with open("location.csv","r") as location_list:
#     main_markers = csv.reader(location_list)
#     for idx,location in enumerate(main_markers):
#         marker_location[location[1]] = location[0].split(',')
