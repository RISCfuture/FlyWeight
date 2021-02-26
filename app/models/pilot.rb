# Pilots are the primary users of the application, and the only ones which can
# be authenticated. Pilots are uniquely identified by their email.
# Authentication is handled by Devise.
#
# Associations
# ------------
#
# |           |                                     |
# |:----------|:------------------------------------|
# | `flights` | The Flights this pilot has created. |
#
# Properties
# ----------
#
# |         |                                                                                    |
# |:--------|:-----------------------------------------------------------------------------------|
# | `name`  | The pilot's name.                                                                  |
# | `email` | The pilot's email address, used for identifying the pilot and for password resets. |
#
# Other properties are created by and used by Devise for authentication and
# password management.

class Pilot < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :flights, dependent: :delete_all

  validates :name,
            presence: true,
            length:   {maximum: 100}
end
