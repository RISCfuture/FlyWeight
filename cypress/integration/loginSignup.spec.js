/// <reference types="cypress" />

describe('Sign Up', () => {
  it('rejects invalid signups', () => {
    cy.visit('/')

    cy.get('#signup-tab').click()
    cy.get('#signup_pilot_name').type('Sancho Sample')
    cy.get('#signup_pilot_email').type('sancho@example.com')
    cy.get('#signup_pilot_password').type('password123')
    cy.get('#signup_pilot_password_confirmation').type('password123')
    cy.get('#signup_submit').click()

    cy.location.should('be', 'http://localhost:5000')
    cy.get('#error-details ul').should('have.length', 1)
  })
})

describe('Log In', () => {

})
