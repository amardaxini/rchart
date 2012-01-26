#!/usr/bin/env ruby
# -*- mode: ruby; ruby-indent-level: 2; indent-tabs-mode: t; tab-width: 2 -*- vim: sw=2 ts=2 et ft=ruby fileencoding=utf-8

require_relative 'helper'

require 'rchart'

class TestRchart < Test::Unit::TestCase

  def test_draw_scale_small_x
    p = create_small_x_dataset
    ch = create_generic_graph

    ticks = 1
    ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_START0,128,128,128,true,0,1,false,ticks, false)
    assert_operator( ch.instance_variable_get( :@division_ratio ), :>, 0, %Q{should have a non-zero ratio} )
  end

  def test_draw_scale_large_x
    p = create_large_x_dataset
    ch = create_generic_graph

    ticks = 1
    ch.draw_scale(p.get_data,p.get_data_description,Rchart::SCALE_START0,128,128,128,true,0,1,false,ticks, false)
    assert_operator( ch.instance_variable_get( :@division_ratio ), :>, 0, %Q{should have a non-zero ratio} )
  end

  def test_draw_xy_scale_small_x
    p = create_small_x_dataset
    ch = create_generic_graph

    ticks = 1
    ch.draw_xy_scale(p.get_data,p.get_data_description,'y','x',128,128,128,true,0)
    assert_operator( ch.instance_variable_get( :@x_division_ratio ), :>, 0, %Q{should have a non-zero ratio} )
  end

  def test_draw_xy_scale_large_x
    p = create_large_x_dataset
    ch = create_generic_graph

    ticks = 1
    ch.draw_xy_scale(p.get_data,p.get_data_description,'y','x',128,128,128,true,0)
    assert_operator( ch.instance_variable_get( :@x_division_ratio ), :>, 0, %Q{should have a non-zero ratio} )
  end

#
# standard creation methods
#
  def create_small_x_dataset
    p = Rdata.new
    x = 0
    8.times do
      p.add_point(x, 'x')
      y = x * x
      p.add_point(y, 'y')
      x += 1
    end
    p.add_serie( 'y' )
    p.set_abscise_label_serie('x')
    return p
  end

  def create_large_x_dataset
    p = Rdata.new
    x = 0
    8.times do
      xreal = x * 10000
      p.add_point(xreal, 'x')
      y = x * x
      p.add_point(y, 'y')
      x += 1
    end
    p.add_serie( 'y' )
    p.set_abscise_label_serie('x')
    return p
  end

  def create_generic_graph
    ch = Rchart.new(1024,768)
    ch.set_graph_area(100, 100, 824, 568 )
    ch.draw_graph_area(255,255,255,false)
    return ch
  end
end
