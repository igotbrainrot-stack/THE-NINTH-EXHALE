extends RefCounted
## Canonical early arsenal values, from the Master Bible.
const ARSENAL = {
    "covenant": {"name":"COVENANT PISTOL", "item":"wp_covenant_pistol", "damage":24, "interval":0.42, "mag":6, "reload":1.8, "range":24.0, "reserve":120, "sound":"ledger", "heat":0},
    "coil": {"name":"COIL SHOTGUN", "item":"wp_coil_shotgun", "damage":8, "pellets":8, "interval":1.05, "mag":2, "reload":1.6, "range":9.0, "reserve":40, "sound":"shutter", "heat":0},
    "nail": {"name":"NAIL STORM", "item":"wp_nail_storm", "damage":8, "interval":0.085, "mag":60, "reload":2.5, "range":15.0, "reserve":240, "sound":"rivet", "heat":3},
    "choir": {"name":"CHOIRBREAKER", "item":"wp_choirbreaker", "damage":30, "interval":0.44, "mag":12, "reload":2.2, "range":28.0, "reserve":72, "sound":"cancel", "heat":0}
}
const SLOTS = ["covenant", "coil", "nail", "choir"]
static func spec(id: String) -> Dictionary:
    return ARSENAL.get(id, ARSENAL["covenant"])
static func ids() -> Array:
    return SLOTS.duplicate()
