import flatpickr from 'flatpickr'
import { parseISO } from 'date-fns'
import BaseController from 'controllers/BaseController'

/**
 * Controller for views under `/flights`. This controller generates the Date
 * Picker on the new- and edit-flight forms.
 */

export default class FlightsController extends BaseController {
  static targets = ['date']

  declare dateTarget: HTMLElement

  picker!: flatpickr.Instance

  /** @private */
  connect() {
    super.connect()

    let date: Date
    if (this.dateTarget.hasAttribute('value')) date = parseISO(this.dateTarget.getAttribute('value'))
    else date = new Date()

    this.picker = flatpickr(this.dateTarget, {
      altInput: true,
      closeOnSelect: true,
      defaultDate: date,
      // minDate: new Date(),
      nextArrow: '&raquo;',
      prevArrow: '&laquo;'
    })
  }
}
