from crush.analyze import Analyze

f=open("crushmap-ceph.json", "r")
crushmap = f.read()

analyzer = Analyze()
analyzer.analyze_crushmap(crushmap)
analyze_params = analyzer.analyze()
output = analyzer.analyze_report(analyze_params)
print(output)
