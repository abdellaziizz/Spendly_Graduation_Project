from backend.services.overrun_predictor import OverrunPredictor
p = OverrunPredictor.predict_overrun(500, 1000, [], 30, 15)
print('TYPE', type(p.risk_level))
print('VALUE', p.risk_level)
print('TODICT', p.to_dict())
