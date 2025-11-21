fetch('header.jsp')
    .then(response => response.text())
    .then(data => {
        const headerElement = document.createElement('div');
        headerElement.innerHTML = data;
        document.getElementById('header-placeholder').appendChild(headerElement);

// ✅ 드롭다운 이벤트 연결 (header가 DOM에 삽입된 후에 해야 함)
        const button = headerElement.querySelector('#categoryBtn');
        const dropdown = headerElement.querySelector('#dropdownMenu');

        if (button && dropdown) {
            button.addEventListener('click', function (e) {
                dropdown.classList.toggle('active');
                e.stopPropagation();
            });

            document.addEventListener('click', function (e) {
                if (!dropdown.contains(e.target) && e.target !== button) {
                    dropdown.classList.remove('active');
                }
            });
        }
        const profileToggle = document.getElementById('profileToggle');
        const userNameToggle = document.getElementById('userNameToggle');
        const userDropdown = document.getElementById('userDropdown');
        const profileInfo = document.getElementById('profileInfo');

        // 토글 이벤트 처리 함수
        function toggleProfileDropdown(e) {
            if (userDropdown) {
                userDropdown.classList.toggle('active');
            }
        }

        // 요소가 존재할 때만 리스너 등록 (로그인 상태일 때)
        if (profileToggle && userNameToggle && userDropdown && profileInfo) {

            // 프로필 아이콘 또는 이름을 클릭하면 드롭다운 토글
            profileToggle.addEventListener('click', toggleProfileDropdown);
            userNameToggle.addEventListener('click', toggleProfileDropdown);

            // 프로필 정보 영역 내부에서 발생하는 클릭 이벤트는 문서 클릭 이벤트로 전달되는 것을 막아,
            // 열자마자 닫히는 현상(버블링)을 방지합니다.
            profileInfo.addEventListener('click', function(e) {
                e.stopPropagation();
            });

            // 문서 클릭 시 드롭다운 닫기
            document.addEventListener('click', function (e) {
                userDropdown.classList.remove('active');
            });
        }
    });