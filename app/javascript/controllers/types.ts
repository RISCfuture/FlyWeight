import {
  FormSubmission,
  FormSubmissionResult
} from '@hotwired/turbo/dist/types/core/drive/form_submission'

export type HTMLElementEvent<T extends HTMLElement> = Event & {
  target: T;
  currentTarget: T;
}

export interface TurboSubmitEndEvent {
  target: HTMLFormElement;
  detail: FormSubmissionResult & {
    formSubmission: FormSubmission
  }
}
