
import sys
import logging

import ismrmrd
import gadgetron.external

import tkinter as tk
import multiprocessing

import matplotlib

matplotlib.use('TkAgg')

import numpy as np
import matplotlib.pyplot as plt

from multimethod import multimethod


@multimethod
def visualize(acquisition: ismrmrd.Acquisition, index):
    logging.info(f"Visualizing Acquisition {index}")

    plt.title(f"Acquisition {index} [Magnitude; Channel 0]")
    plt.plot(np.abs(acquisition.data[0, :]))
    plt.axis('off')


@multimethod
def visualize(bucket: gadgetron.types.AcquisitionBucket, index):
    logging.info(f"Visualizing AcquisitionBucket {index}")

    plt.title(f"AcquisitionBucket {index} [Magnitude; Channel 0]")
    for acquisition in bucket.data:
        plt.plot(np.abs(acquisition.data[0, :]))
    plt.axis('off')


@multimethod
def visualize(buffer: gadgetron.types.ReconData, index):
    logging.info(f"Visualizing ReconData {index}")

    data = buffer.bits[0].data.data

    plt.title(f"ReconData {index} [Magnitude; Channel 0]")
    plt.imshow(np.log(np.abs(np.squeeze(data[:, :, 0, 0]))))
    plt.axis('off')


@multimethod
def visualize(image_array: gadgetron.types.ImageArray, index):
    logging.info(f"Visualizing ImageArray {index}")

    plt.title(f"ImageArray {index}")
    plt.imshow(np.abs(np.squeeze(image_array.data)))
    plt.axis('off')


@multimethod
def visualize(image: ismrmrd.Image, index):
    logging.info(f"Visualizing Image {index}")

    plt.title(f"Image {index}")
    plt.imshow(np.abs(np.squeeze(image.data)))
    plt.axis('off')


def handle_connection(connection):
    logging.info("Connection established; visualizing.")

    root = tk.Tk()
    root.title("Visualization Controls")
    root.geometry('240x302')

    figure = plt.figure()
    figure.show()

    step_size = 1

    def increase_step_size(event):
        nonlocal step_size
        step_size = step_size * 2
        logging.info(f"Increasing step size; now {step_size}")

    def decrease_step_size(event):
        nonlocal step_size
        step_size = max(1, step_size // 2)
        logging.info(f"Decreasing step size; now {step_size}")

    root.bind(']', increase_step_size)
    root.bind('[', decrease_step_size)

    items = enumerate(connection)

    def drop_n_items(n):
        for i in range(n):
            next(items)

    def get_next_item():
        drop_n_items(step_size - 1)
        return next(items)

    def visualize_next(*args, **kwargs):
        index, item = get_next_item()

        figure.clear()
        visualize(item, index)
        figure.canvas.draw()
        figure.canvas.flush_events()

    logo = tk.PhotoImage(file='gadgetron_logo.png')

    canvas = tk.Canvas(root, bg='#373e48')
    canvas.pack(expand='yes', fill='both')
    canvas.create_image(60, 60, image=logo, anchor='nw')

    next_button = tk.Button(root, text="Next Item", command=visualize_next)
    next_button.pack(expand='yes', fill='both')

    root.mainloop()
    plt.close(figure)

    logging.info("Visualization complete; closing connection.")


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")

    while True:
        gadgetron.external.listen(18000, handle_connection)
