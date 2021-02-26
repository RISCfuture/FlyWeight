Cypress.Commands.add(
  'dataCy',
  { prevSubject: 'optional' },
  (subject, value, options) => {
    if (subject) {
      return cy.wrap(subject).find(`[data-cy=${value}]`, options)
    }
    return cy.get(`[data-cy=${value}]`, options)
  }
)
