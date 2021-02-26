import BaseController from 'controllers/BaseController'
import { HTMLElementEvent } from 'controllers/types'

/**
 * Controller for the home page `/`. This controller manages the login/signup
 * tabbed view.
 *
 * @!attribute index
 *   The currently selected tab (zero-indexed). This field is the source of
 *   truth for the tab view. It is watched, and the front-end is kept in sync
 *   with its value.
 */

export default class HomeController extends BaseController {
  /** @private */
  static targets = ['tab', 'content']

  declare tabTargets: HTMLElement[]

  declare contentTargets: HTMLElement[]

  /** @private */
  static values = { index: Number }

  indexValue!: number

  /** @private */
  initialize() {
    this.indexValue = 0
    this.render()
  }

  /**
   * Called when a tab is clicked. Activates the appropriate content pane.
   *
   * @param event The event that invoked this action.
   */

  switch(event: HTMLElementEvent<HTMLUListElement>) {
    this.indexValue = Number.parseInt(event.target.getAttribute('data-index'), 10)
  }

  /** @private */
  indexValueChanged() {
    this.render()
  }

  private render() {
    this.tabTargets.forEach((element, index) => {
      if (index === this.indexValue) {
        element.classList.add('active')
        element.setAttribute('aria-selected', 'true')
      } else {
        element.classList.remove('active')
        element.setAttribute('aria-selected', 'false')
      }
    })
    this.contentTargets.forEach((element, index) => {
      const e = element
      e.hidden = (index !== this.indexValue)
    })
  }
}
