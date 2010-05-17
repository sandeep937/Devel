;;; advices_KONIX.el --- Here are the pieces of advice I customize

;; Copyright (C) 2010

;; Author:  <leumas80@hotmail.com>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

;; ################################################################################
;; I want that when appt shows me the appointment, it still appear for
;; some time but does not directly vanish because if I am not in front
;; of my computer I would have never seen it and it is a possible miss
;; of information. Then I ask it to stay at least 1 day (86400
;; seconds) in my emacs if I don't do anything.
;;
;; The cool thing is that when there is the input that let the message
;; disapear, the character will be correctly handled by emacs and
;; there will not be any lack of character in my text
;; ################################################################################
(defadvice appt-delete-window (before wait-for-confirmation ())
  "Wait an entire day that the user says he has seen the appt"
  (message "Please press anything to say you have seen your appointment")
  (sit-for 86400)
  )
(ad-activate 'appt-delete-window)


;;; advices_KONIX.el ends here
