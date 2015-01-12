#!/usr/bin/env python
# -*- coding:utf-8 -*-

import itertools
import matplotlib
from matplotlib.pyplot import subplots
import numpy

def scatter_plots(inputs, names=None, title=None, nrows=4):
  """inputs: lines of vectors"""
  inputs = numpy.array(inputs)
  len_of_input = len(inputs[0])
  assert names is None or len_of_input == len(names), (
    "The names and the inputs must have the same length"
  )

  ij = [
    (i, j)
    for i, j in itertools.product(
        range(len_of_input),
        range(len_of_input))
    if i < j]

  ncols = len(ij) / nrows + 1
  f, sp = subplots(nrows, ncols)
  if title:
    f.suptitle(title)
  for a, (i,j) in zip(sp.flat, ij):
    a.scatter(inputs[:, i], inputs[:, j])
    a.set_title("{} vs {}".format(names and names[i] or i,
                                  names and names[j] or j))

def plot_all(inputs, names=None, title=None, nrows=4):
  """inputs: lines of vectors"""
  len_of_input = len(inputs[0])
  assert names is None or len_of_input == len(names), (
      "The names and the inputs must have the same length"
  )
  nrows = min(nrows, len_of_input)
  ncols = ( (len_of_input - 1) / nrows ) + 1
  f, sp = subplots(nrows, ncols)
  if isinstance(sp, matplotlib.axes.Axes):
      sp = numpy.array([sp,])
  if title:
      f.suptitle(title)
  for figure, name in zip(sp.flat, inputs.dtype.names):
      figure.plot(inputs[name])
      figure.set_title(name)
