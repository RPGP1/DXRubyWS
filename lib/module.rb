# Mix-in�p�̃��W���[��
# �����ꃂ�W���[���P�ʂɕ������邩������Ȃ��B
# �ǂ�����ǃ}�E�X�C�x���g���E���Ĕ���E�������ăV�O�i�������邾���Ȃ̂ŁA
# ���[�U���x���ō��Ȃ����̂͂܂������Ȃ��B

module WS
  # �}�E�X�{�^�����������u�Ԃ�:click�V�O�i���𔭍s����
  module Clickable
    def on_mouse_down(tx, ty, button)
      signal(:click, tx, ty)
      super
    end
  end

  # Windows�̃{�^���̂悤�Ƀ}�E�X�{�^���𗣂����u�Ԃ�:click�V�O�i���𔭍s����
  module ButtonClickable
    def on_mouse_down(tx, ty, button)
      WS.capture(self)
      super
    end

    def on_mouse_up(tx, ty, button)
      WS.capture(nil)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      signal(:click, tx, ty) if @hit_cursor === self
      super
    end
  end

  # �}�E�X�Ńh���b�O�����Ƃ���:drag_move�V�O�i���𔭍s����
  # �܂��A�{�^����������:drag_start�A��������:drag_end�𔭍s����
  # :drag_move�V�O�i���̈����͑��΍��W
  # �C���X�^���X�ϐ�@dragging_flag���g��
  module Draggable
    def initialize(*args)
      super
      @dragging_flag = false
    end

    def on_mouse_down(tx, ty, button)
      @dragging_flag = true
      WS.capture(self)
      @drag_old_x = tx
      @drag_old_y = ty
      signal(:drag_start)
      super
    end

    def on_mouse_up(tx, ty, button)
      @dragging_flag = false
      WS.capture(nil)
      signal(:drag_end)
      super
    end

    def on_mouse_move(tx, ty)
      signal(:drag_move, tx - @drag_old_x, ty - @drag_old_y) if @dragging_flag
      super
    end
  end

  # �I�u�W�F�N�g�Ƀ}�E�X�J�[�\�����悹���Ƃ���:mouse_over�A���ꂽ�Ƃ���:mouse_out�V�O�i���𔭍s����
  module MouseOver
    def on_mouse_over
      signal(:mouse_over)
      super
    end

    def on_mouse_out
      signal(:mouse_out)
      super
    end
  end

  # �I�u�W�F�N�g�̃{�[�_�[������ŃT�C�Y�ύX�����Ƃ���resize���\�b�h���ĂԁB
  # �܂��A�T�C�Y�ύX�J�n����resize_start�A�I������resize_end���\�b�h���ĂԁB
  # �������Ă񂾂��Ƃœ����̃V�O�i���𔭍s����B
  # �}�E�X�J�[�\���̌����ڂ�ύX����@�\�t���B
  # �C���X�^���X�ϐ�@resize_top/@resize_left/@resize_right/@resize_bottom���g��
  module Resizable
    def on_mouse_down(tx, ty, button)
      if @resize_top or @resize_left or @resize_right or @resize_bottom
        WS.capture(self)
        @drag_old_x = tx
        @drag_old_y = ty
        resize_start
        signal(:resize_start)
      end
      super
    end

    def on_mouse_up(tx, ty, button)
      WS.capture(nil)
      Input.set_cursor(IDC_ARROW)
      resize_end
      signal(:resize_end)
      super
    end

    def on_mouse_move(tx, ty)
      if WS.captured?(self)
        x1, y1, width, height = self.x, self.y, self.image.width, self.image.height

        if @resize_left
          width += @drag_old_x - tx
          x1 += tx - @drag_old_x
          tx -= tx - @drag_old_x
        end

        if @resize_top
          height += @drag_old_y - ty
          y1 += ty - @drag_old_y
          ty -= ty - @drag_old_y
        end

        if @resize_right
          width += tx - @drag_old_x
        end

        if @resize_bottom
          height += ty - @drag_old_y
        end

        if width > 32
          @drag_old_x = tx
        else
          width = 32
          x1 = self.x
        end
        if height > 32
          @drag_old_y = ty
        else
          height = 32
          y1 = self.y
        end
        move(x1, y1)
        resize(width, height)
      else
        border_width = @border_width ? @border_width : 2
        @resize_top = ty < border_width
        @resize_left = tx < border_width
        @resize_right = self.image.width - tx <= border_width
        @resize_bottom = self.image.height - ty <= border_width
        case true
        when @resize_top
          case true
          when @resize_left
            Input.set_cursor(IDC_SIZENWSE)
          when @resize_right
            Input.set_cursor(IDC_SIZENESW)
          else
            Input.set_cursor(IDC_SIZENS)
          end
        when @resize_bottom
          case true
          when @resize_left
            Input.set_cursor(IDC_SIZENESW)
          when @resize_right
            Input.set_cursor(IDC_SIZENWSE)
          else
            Input.set_cursor(IDC_SIZENS)
          end
        when @resize_left
          Input.set_cursor(IDC_SIZEWE)
        when @resize_right
          Input.set_cursor(IDC_SIZEWE)
        else
          Input.set_cursor(IDC_ARROW)
        end
      end
      super
    end

    def on_mouse_out
      Input.set_cursor(IDC_ARROW)
      super
    end

    def resize_start
    end
    def resize_end
    end
  end

  # �_�u���N���b�N�����Ƃ���2��ڂ̃{�^����������:doubleclick�V�O�i���𔭍s����
  # �C���X�^���X�ϐ�@doubleclickcout/@doubleclick_x/@doubleclick_y���g��
  # �_�u���N���b�N�̗]�T��30�t���[��/�c��5pixel�ȓ��ŌŒ�
  module DoubleClickable
    def on_mouse_down(tx, ty, button)
      if @doubleclickcount and @doubleclickcount > 0 and
         (@doubleclick_x - tx).abs < 5 and (@doubleclick_y - ty).abs < 5
          signal(:doubleclick)
      else
        @doubleclickcount = 30
        @doubleclick_x = tx
        @doubleclick_y = ty
      end
      super
    end

    def update
      @doubleclickcount -= 1 if @doubleclickcount and @doubleclickcount > 0
      super
    end
  end

  # �X�N���[���o�[�̃{�^���̂悤�ɃI�[�g���s�[�g��:click�V�O�i���𔭍s��������
  # ���̃V�O�i����update���ɔ�������
  module RepeatClickable
    def initialize(*args)
      super
      @downcount = 0
    end
    def on_mouse_down(tx, ty, button)
      @old_tx, @old_ty = tx, ty
      WS.capture(self)
      @downcount = 20
      super
      signal(:click, tx, ty)
    end

    def on_mouse_up(tx, ty, button)
      WS.capture(nil)
      @downcount = 0
      super
    end

    def on_mouse_move(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      @image_flag = (WS.captured?(self) and @hit_cursor === self)
      super
    end

    def update
      if @downcount > 0
        @downcount -= 1
        if @downcount == 0
          @downcount = 5
          signal(:click, @old_tx, @old_ty)
        end
      end
      super
    end
  end
end
