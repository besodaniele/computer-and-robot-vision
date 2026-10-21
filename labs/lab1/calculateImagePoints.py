import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import csv
image_path = "image.jpg"  # change this to your image file

img = mpimg.imread(image_path)

fig, ax = plt.subplots()
ax.imshow(img)
ax.set_title("Click points (right-click to remove last, Enter to finish)")

# n=-1 means unlimited clicks; the user ends the selection with Enter or by closing the window
points = plt.ginput(n=-1, timeout=0, show_clicks=True)
plt.close(fig)

# Coordinates are (x, y) with the origin at the top-left corner of the image
for i, (x, y) in enumerate(points, start=1):
    print(f"Point {i}: x={x:.1f}, y={y:.1f}")

# Integer pixel coordinates, if you need them
pixel_coords = [(int(round(x)), int(round(y))) for x, y in points]

# Save the coordinates to a CSV file
with open("points.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["u", "v"])
    writer.writerows(pixel_coords)