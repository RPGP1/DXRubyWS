require 'dxruby'
require_relative './core'
require_relative './window'
require_relative './button.rb'
require_relative './label'
require_relative './image'

# �E�B���h�E�V�X�e��
module WS
  class WSDesktop < WSContainer
    def initialize
      super(0, 0, Window.width, Window.height)
    end
  end

  @@desktop = WSDesktop.new
  @@cursor = Sprite.new
  @@mouse_flag = false
  @@capture = nil
  @@over_object = nil

  # �E�B���h�E�V�X�e���̃��C������
  def self.update
    oldx, oldy = @@cursor.x, @@cursor.y
    @@cursor.x, @@cursor.y = Input.mouse_pos_x, Input.mouse_pos_y

    # �}�E�X�J�[�\���̈ړ�����
    if oldx != @@cursor.x or oldy != @@cursor.y
      # �L���v�`������Ă�����@@capture�̃��\�b�h���Ă�
      if @@capture
        tx, ty = @@capture.get_global_vertex
        @@over_object = @@capture.on_mouse_move(@@cursor.x - tx, @@cursor.y - ty)
      else
        @@over_object = @@desktop.on_mouse_move(@@cursor.x, @@cursor.y)
      end
    end

    # �{�^��������
    if Input.mouse_down?(M_LBUTTON) and @@mouse_flag == false
      @@mouse_flag = true
      @@desktop.on_mouse_down(@@cursor.x, @@cursor.y, M_LBUTTON)
    end

    # �{�^���������B�L���v�`������Ă���@@capture�̃��\�b�h���Ă�
    if !Input.mouse_down?(M_LBUTTON) and @@mouse_flag == true
      @@mouse_flag = false
      if @@capture
        tx, ty = @@capture.get_global_vertex
        @@capture.on_mouse_up(@@cursor.x - tx, @@cursor.y - ty, M_LBUTTON)
      else
        @@desktop.on_mouse_up(@@cursor.x, @@cursor.y, M_LBUTTON)
      end
    end

    Sprite.update @@desktop
    Sprite.draw @@desktop
  end

  def self.capture(obj)
    @@capture = obj
  end

  def self.desktop
    @@desktop
  end

  def self.over_object
    @@over_object
  end
end

