/* eslint-disable class-methods-use-this */

import { Controller } from 'stimulus'
import { visit } from '@hotwired/turbo'
import { HTMLElementEvent, TurboSubmitEndEvent } from 'controllers/types'

/**
 * @abstract
 *
 * Abstract superclass for all Stimulus controllers in this application. This
 * controller expands Turbo Frames to support redirect responses from form
 * submissions. A successful form submission will result in a 303 See Other
 * response, which will cause Turbo Frames to execute the redirect.
 */

export default class BaseController extends Controller {
  /** @private */
  connect(): void {
    this.element.addEventListener(
      'turbo:submit-end',
      event => this.next(<TurboSubmitEndEvent>(<unknown>event))
    )
  }

  /**
   * Dispatch form submit buttons to this action. This action will disable the
   * submit button while the form is processing.
   *
   * @param event The event that invoked this action.
   */

  submit(event: HTMLElementEvent<HTMLInputElement>): void {
    const form = event.target.closest('form')
    form.querySelectorAll('input[type=submit], input[type=button], button')
      .forEach((element: HTMLInputElement | HTMLButtonElement) => {
        const e = element
        e.disabled = true
        e.classList.add('processing')
      })
    form.dispatchEvent(new CustomEvent('submit', { bubbles: true }))
  }

  private

  next(event: TurboSubmitEndEvent): void {
    if (event.detail.success) {
      visit(event.detail.fetchResponse.response.url)
    }
  }
}
